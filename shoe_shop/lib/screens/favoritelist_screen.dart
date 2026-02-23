import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_shop/models/shoe.dart';
import 'shoe_detail_screen.dart';

class FavoritelistScreen extends StatelessWidget {
  final String uid;

  const FavoritelistScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Favorite List",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shoes')
            .where('is_favorite', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final favoritelist = snapshot.data!.docs
              .map((doc) => Shoe.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
              .toList();

          if (favoritelist.isEmpty) {
            return const Center(child: Text("Your favorite list is empty"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favoritelist.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final shoe = favoritelist[index];

              return FavoriteListItem(
                shoe: shoe,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShoeDetailScreen(shoe: shoe, onFavorite: () {}),
                  ),
                ),
                onDelete: () async {
                  await FirebaseFirestore.instance
                      .collection('shoes')
                      .doc(shoe.id)
                      .update({'is_favorite': false});
                },
                onMoveToCart: () async {
                  // Check if shoe has a size selected
                  // Using 'shoe.sizes' to match your provided code
                  if (shoe.sizes == null || shoe.sizes == "" || shoe.sizes == "N/A") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a size first")),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShoeDetailScreen(shoe: shoe, onFavorite: () {}),
                      ),
                    );
                  } else {
                    try {
                      final cartRef = FirebaseFirestore.instance
                          .collection('cart')
                          .doc(uid)
                          .collection('items');

                      await cartRef.add({
                        'shoeId': shoe.id,
                        'price': shoe.price,
                        'oldPrice': shoe.oldPrice ?? shoe.price,
                        'quantity': 1,
                        'image': shoe.imageUrl, 
                        'name': shoe.name,
                        'size': shoe.sizes,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      await FirebaseFirestore.instance
                          .collection('shoes')
                          .doc(shoe.id)
                          .update({'is_favorite': false});
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class FavoriteListItem extends StatelessWidget {
  final Shoe shoe;
  final Future<void> Function() onDelete;
  final Future<void> Function() onMoveToCart;
  final VoidCallback onTap;

  const FavoriteListItem({
    super.key,
    required this.shoe,
    required this.onDelete,
    required this.onMoveToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Logic to handle size display text
    final String sizeDisplay = (shoe.sizes == null || shoe.sizes == "" || shoe.sizes == "N/A") 
        ? "Pick a size" 
        : shoe.sizes.toString();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10, 
              offset: const Offset(0, 4), 
              color: Colors.black.withOpacity(0.05)
            )
          ],
        ),
        child: Row(
          children: [
            /// IMAGE
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), 
                color: const Color(0xFFF3F4F6)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: shoe.imageUrl!.startsWith('http') 
                    ? Image.network(shoe.imageUrl!, fit: BoxFit.contain)
                    : Image.asset(shoe.imageUrl!, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 16),

            /// INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          shoe.name, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        )
                      ),
                      GestureDetector(
                        onTap: () => onDelete(), 
                        child: const Icon(Icons.close, size: 20, color: Colors.grey)
                      ),
                    ],
                  ),

                  // --- SIZE LABEL ADDED HERE ---
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Size: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // "Size:" is always black
                            fontSize: 13,
                            
                          ),
                        ),
                        TextSpan(
                          text: sizeDisplay,
                          style: TextStyle(
                            // If it says "Pick a size", make it Red, otherwise make it Black
                            color: sizeDisplay == "Pick a size" 
                                ? const Color.fromARGB(255, 230, 3, 3) 
                                : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "\$${shoe.price.toStringAsFixed(0)}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                      ),
                      if (shoe.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          "\$${shoe.oldPrice!.toStringAsFixed(0)}", 
                          style: const TextStyle(
                            color: Colors.red, 
                            fontSize: 12, 
                            decoration: TextDecoration.lineThrough
                          )
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, height: 38,
                    child: ElevatedButton(
                      onPressed: onMoveToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, 
                        foregroundColor: Colors.white, 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      child: const Text(
                        "Move to cart", 
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}