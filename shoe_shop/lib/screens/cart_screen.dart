import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sucessful_order_screen.dart'; 

class ShoppingCartScreen extends StatefulWidget {
  final String uid;

  const ShoppingCartScreen({super.key, required this.uid});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  Stream<QuerySnapshot> getCartStream() {
    return FirebaseFirestore.instance
        .collection('cart')
        .doc(widget.uid)
        .collection('items')
        .snapshots();
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity < 1) return;
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(widget.uid)
        .collection('items')
        .doc(cartItemId)
        .update({'quantity': quantity});
  }

  Future<void> deleteItem(String cartItemId) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(widget.uid)
        .collection('items')
        .doc(cartItemId)
        .delete();
  }

  // --- RECORD ORDER WITH SIZE ---
  Future<void> _placeOrder(List<QueryDocumentSnapshot> cartDocs) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      List<Map<String, dynamic>> orderItems = []; 
      double totalSelling = 0;
      double platformFee = 2;

      for (var doc in cartDocs) {
        final cartData = doc.data() as Map<String, dynamic>;
        final shoeId = cartData['shoeId'];
        final quantity = cartData['quantity'] ?? 1;
        final size = cartData['size'] ?? 'N/A'; // Get size from cart item

        DocumentSnapshot shoeDoc = await FirebaseFirestore.instance
            .collection('shoes')
            .doc(shoeId.toString())
            .get();

        if (shoeDoc.exists) {
          final shoeData = shoeDoc.data() as Map<String, dynamic>;
          double price = (shoeData['price'] ?? 0).toDouble();
          double oldPrice = (shoeData['old_price'] ?? price).toDouble();

          totalSelling += price * quantity;

          orderItems.add({
            '0': shoeId.toString(),           
            '1': shoeData['name'] ?? '',      
            '2': price,                       
            '3': oldPrice,                    
            '4': quantity,                    
            '5': shoeData['image_url'] ?? '', 
            '6': size,                        // Added Size as index 6
          });
        }
      }

      await FirebaseFirestore.instance.collection('order').add({
        'deliveryStatus': "pending...",
        'items': orderItems,
        'orderDate': FieldValue.serverTimestamp(),
        'paymentStatus': "Completed",
        'totalAmount': totalSelling + platformFee,
        'userId': widget.uid,
      });

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in cartDocs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) {
        Navigator.pop(context); 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrderConfirmedScreen()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("My shopping cart", style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCartStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final cartDocs = snapshot.data!.docs;
          if (cartDocs.isEmpty) return const Center(child: Text("Your cart is empty"));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) => _buildCartItem(cartDocs[index]),
                ),
              ),
              _buildSummarySection(cartDocs),
              _buildBottomBar(cartDocs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(QueryDocumentSnapshot cartItem) {
    final data = cartItem.data() as Map<String, dynamic>;
    final shoeId = data['shoeId'];
    final quantity = data['quantity'] ?? 1;
    final size = data['size'] ?? 'N/A'; // Get size from Firestore cart record

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('shoes').doc(shoeId.toString()).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.data() == null) return const SizedBox();
        final shoe = snapshot.data!.data() as Map<String, dynamic>;
        final price = (shoe['price'] ?? 0).toDouble();
        final oldPrice = (shoe['old_price'] ?? price).toDouble();
        final image = shoe['image_url'] ?? '';
        final name = shoe['name'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120, width: 120,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: image.startsWith('http') ? Image.network(image, fit: BoxFit.contain) : Image.asset(image, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    
                    // --- SIZE DISPLAYED HERE ---
                    const SizedBox(height: 4),
                    Text("Size: $size", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text("\$${price.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(width: 10),
                        Text("\$${oldPrice.toStringAsFixed(0)}", style: const TextStyle(color: Colors.red, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              _qtyBtn(Icons.remove, () => updateQuantity(cartItem.id, quantity - 1)),
                              Text("$quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
                              _qtyBtn(Icons.add, () => updateQuantity(cartItem.id, quantity + 1)),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => deleteItem(cartItem.id), icon: const Icon(Icons.delete_outline, color: Colors.red))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(6.0), child: Icon(icon, size: 18)));

  Widget _buildSummarySection(List<QueryDocumentSnapshot> cartDocs) {
    double totalMRP = 0, totalSelling = 0, platformFee = 2;
    for (var doc in cartDocs) {
      final data = doc.data() as Map<String, dynamic>;
      double price = (data['price'] ?? 0).toDouble();
      double oldPrice = (data['oldPrice'] ?? price).toDouble();
      int quantity = (data['quantity'] ?? 1);
      totalMRP += oldPrice * quantity;
      totalSelling += price * quantity;
    }
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _summaryRow("Total MRP", "\$${totalMRP.toStringAsFixed(0)}"),
          _summaryRow("Discount on MRP", "-\$${(totalMRP - totalSelling).toStringAsFixed(0)}", textColor: Colors.red),
          _summaryRow("Platform fee", "\$${platformFee.toStringAsFixed(0)}"),
          _summaryRow("Shipping fee", "Free", textColor: Colors.red),
          const Divider(height: 30),
          _summaryRow("Total Amount", "\$${(totalSelling + platformFee).toStringAsFixed(0)}", isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool isBold = false, Color textColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: textColor)),
      ]),
    );
  }

  Widget _buildBottomBar(List<QueryDocumentSnapshot> cartDocs) {
    double total = 0;
    for (var doc in cartDocs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['price'] ?? 0) * (data['quantity'] ?? 1);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("\$${(total + 2).toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("view detail", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
        const SizedBox(width: 30),
        Expanded(
          child: SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: () => _placeOrder(cartDocs),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Continue", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        )
      ]),
    );
  }
}