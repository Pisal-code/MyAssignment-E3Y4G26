import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_shop/models/shoe.dart';
import '../widgets/shoe_card.dart';
import 'shoe_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<Shoe> favoritelist;

  const SearchScreen({
    super.key,
    required this.favoritelist, required Function(Shoe) onAddToFavoritelist,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Firestore stream with search filter
  Stream<List<Shoe>> _shoeStream() {
    return FirebaseFirestore.instance.collection('shoes').snapshots().map(
          (snapshot) => snapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => Shoe.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
              .where((shoe) => shoe.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList(),
        );
  }

  // Toggle favorite both locally and in Firestore
  Future<void> toggleFavorite(Shoe shoe) async {
    final newValue = !shoe.isFavorite;

    // Update Firestore
    await FirebaseFirestore.instance
        .collection('shoes')
        .doc(shoe.id)
        .update({'is_favorite': newValue});

    // Update local list
    setState(() {
      shoe.isFavorite = newValue;
      if (newValue) {
        if (!widget.favoritelist.any((s) => s.id == shoe.id)) {
          widget.favoritelist.add(shoe);
        }
      } else {
        widget.favoritelist.removeWhere((s) => s.id == shoe.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _circleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: "Search by brand...",
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = "");
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<List<Shoe>>(
                  stream: _shoeStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final shoes = snapshot.data ?? [];
                    if (shoes.isEmpty) {
                      return const Center(child: Text("No shoes found."));
                    }

                    return GridView.builder(
                      itemCount: shoes.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.70,
                      ),
                      itemBuilder: (context, index) {
                        final shoe = shoes[index];
                        final isFavorite = widget.favoritelist.any((s) => s.id == shoe.id);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShoeDetailScreen(
                                  shoe: shoe,
                                  onFavorite: () => toggleFavorite(shoe),
                                ),
                              ),
                            );
                          },
                          child: ShoeCard(
                            shoe: shoe,
                            isFavorite: isFavorite,
                            onFavorite: () => toggleFavorite(shoe),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}