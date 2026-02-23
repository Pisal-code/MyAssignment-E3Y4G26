import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_shop/models/shoe.dart';
import '../widgets/shoe_card.dart';
import 'shoe_detail_screen.dart'; // Ensure this is imported

class SearchScreen extends StatefulWidget {
  final Function(Shoe) onAddToFavoritelist;

  const SearchScreen({super.key, required this.onAddToFavoritelist});

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

  // FIXED: Added docId to the fromMap constructor so Firestore knows which shoe is being updated
  Stream<List<Shoe>> _shoeStream() {
    return FirebaseFirestore.instance.collection('shoes').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Shoe.fromMap(
                  // ignore: unnecessary_cast
                  doc.data() as Map<String, dynamic>, 
                  docId: doc.id, // <--- CRITICAL FIX
                ))
            .where((shoe) =>
                shoe.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList());
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
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.70,
                      ),
                      itemBuilder: (context, index) {
                        final shoe = shoes[index];
                        // FIXED: Added GestureDetector to navigate to detail screen
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShoeDetailScreen(
                                  shoe: shoe,
                                  onFavorite: () => widget.onAddToFavoritelist(shoe),
                                ),
                              ),
                            );
                          },
                          child: ShoeCard(
                            shoe: shoe,
                            onFavorite: () => widget.onAddToFavoritelist(shoe),
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