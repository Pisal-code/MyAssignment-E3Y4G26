import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/shoe.dart';
import '../providers/favorite_provider.dart';
import '../widgets/size_chip.dart';

class ShoeDetailScreen extends StatefulWidget {
  final Shoe shoe;
  final VoidCallback onFavorite;

  const ShoeDetailScreen({super.key, required this.shoe, required this.onFavorite});

  @override
  State<ShoeDetailScreen> createState() => _ShoeDetailScreenState();
}

class _ShoeDetailScreenState extends State<ShoeDetailScreen> {
  int selectedImage = 0;
  int selectedSize = 0;
  int quantity = 1;

  final List<String> sizes = ["UK 6", "UK 7", "UK 8", "UK 9", "UK 10"];

  void toggleFavorite() async {
    final favoriteProvider = context.read<FavoriteProvider>();
    await favoriteProvider.toggleFavorite(widget.shoe);
    widget.onFavorite();
  }

  Future<void> addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('items');

    // Check if item already in cart with same size
    final existingItem = await cartRef
        .where('shoeId', isEqualTo: widget.shoe.id)
        .where('size', isEqualTo: sizes[selectedSize])
        .get();

    if (existingItem.docs.isNotEmpty) {
      await cartRef.doc(existingItem.docs.first.id).update({
        'quantity': existingItem.docs.first['quantity'] + quantity,
      });
    } else {
      await cartRef.add({
        'shoeId': widget.shoe.id,
        'name': widget.shoe.name,
        'price': widget.shoe.price,
        'oldPrice': widget.shoe.oldPrice,
        'image': widget.shoe.imageUrl, // Key used in ShoppingCartScreen
        'size': sizes[selectedSize],
        'quantity': quantity,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Remove from favorites if it was favorited (per-user favorites)
    final favoriteProvider = context.read<FavoriteProvider>();
    await favoriteProvider.removeFromFavorites(widget.shoe.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to cart successfully")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(height: 250, padding: const EdgeInsets.all(20), child: _buildHeroImage())),
                    const SizedBox(height: 24),
                    Text(widget.shoe.category.toUpperCase(), style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(widget.shoe.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildPriceSection(),
                    const SizedBox(height: 24),
                    const Text("Select Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildSizeSelector(),
                    const SizedBox(height: 24),
                    const Text("Quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildQuantitySelector(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    String path = widget.shoe.imageUrl ?? "";
    return path.startsWith("http") ? Image.network(path, fit: BoxFit.contain) : Image.asset(path, fit: BoxFit.contain);
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              final isFav = favoriteProvider.isFavorite(widget.shoe.id);
              return _circleBtn(isFav ? Icons.favorite : Icons.favorite_border, toggleFavorite, iconColor: isFav ? Colors.red : Colors.black);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: const Color.fromRGBO(255, 237, 107, 1), borderRadius: BorderRadius.circular(4)),
          child: Text("\$${widget.shoe.price.toStringAsFixed(0)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        if (widget.shoe.oldPrice != null) ...[
          const SizedBox(width: 12),
          Text("\$${widget.shoe.oldPrice!.toStringAsFixed(0)}", style: const TextStyle(color: Colors.red, decoration: TextDecoration.lineThrough, fontSize: 18)),
        ]
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: List.generate(sizes.length, (i) => SizeChip(label: sizes[i], selected: i == selectedSize, onTap: () => setState(() => selectedSize = i))),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        _qtyBox(Icons.remove, () => setState(() { if (quantity > 1) quantity--; })),
        Container(width: 50, alignment: Alignment.center, child: Text(quantity.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        _qtyBox(Icons.add, () => setState(() => quantity++)),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity, height: 60,
        child: ElevatedButton(
          onPressed: addToCart,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: Text("Add to cart ($quantity)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, {Color iconColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45, width: 45,
        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _qtyBox(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(height: 40, width: 40, decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(10)), child: Icon(icon)),
    );
  }
}

