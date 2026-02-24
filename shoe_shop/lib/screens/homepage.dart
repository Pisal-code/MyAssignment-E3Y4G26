import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shoe_shop/screens/searchscreen.dart';
import '../models/shoe.dart';
import '../widgets/shoe_card.dart';
import '../widgets/category_item.dart';
import 'shoe_detail_screen.dart';

class HomePage extends StatefulWidget {
  final List<Shoe> favoritelist;
  final Function(Shoe) onAddToFavoritelist;

  /// Callbacks for MainScreen to switch tabs
  final VoidCallback onProfileTap;
  final VoidCallback onCartTap;

  const HomePage({
    super.key,
    required this.favoritelist,
    required this.onAddToFavoritelist,
    required this.onProfileTap,
    required this.onCartTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> categories = [
    "Running",
    "Jordan",
    "Skate",
    "Lifestyle",
    "Hiking",
    "Casual",
  ];

  int? _selectedCategoryIndex;
  bool _showAllNewArrival = false;
  bool _showAllRecommended = false;

  late final Stream<List<Shoe>> _shoeStream;

  @override
  void initState() {
    super.initState();
    _shoeStream = FirebaseFirestore.instance
        .collection('shoes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Shoe.fromMap(
                  // ignore: unnecessary_cast
                  doc.data() as Map<String, dynamic>,
                  docId: doc.id,
                ))
            .toList());
  }

  void toggleFavorite(Shoe shoe) async {
    final newValue = !shoe.isFavorite;

    await FirebaseFirestore.instance
        .collection('shoes')
        .doc(shoe.id)
        .update({'is_favorite': newValue});

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

  Future<void> addToCart(String userId, Shoe shoe, {int quantity = 1}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    final doc = await userRef.get();
    List cart = [];
    if (doc.exists) {
      cart = doc['cart'] ?? [];
    }

    final index = cart.indexWhere((item) => item['shoeId'] == shoe.id);
    if (index != -1) {
      cart[index]['quantity'] += quantity;
    } else {
      cart.add({'shoeId': shoe.id, 'quantity': quantity});
    }

    await userRef.update({'cart': cart});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<Shoe>>(
          stream: _shoeStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

            final allShoes = snapshot.data!;
            final filteredShoes = allShoes.where((shoe) {
              return _selectedCategoryIndex == null
                  ? true
                  : shoe.category == categories[_selectedCategoryIndex!];
            }).toList();

            final newArrival = List<Shoe>.from(filteredShoes)
              ..sort((a, b) => b.id.compareTo(a.id));
            final recommended =
                filteredShoes.where((shoe) => shoe.bestSelling).toList();

            final newArrivalToShow =
                _showAllNewArrival ? newArrival : newArrival.take(4).toList();
            final recommendedToShow =
                _showAllRecommended ? recommended : recommended.take(4).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildSearchBar(context),
                  const SizedBox(height: 20),
                  _sectionHeader("Category"),
                  const SizedBox(height: 10),
                  _buildCategoryList(),
                  const SizedBox(height: 20),
                  _sectionHeader(
                    "New Arrival",
                    showViewAll: true,
                    isExpanded: _showAllNewArrival,
                    onViewAll: () =>
                        setState(() => _showAllNewArrival = !_showAllNewArrival),
                  ),
                  const SizedBox(height: 10),
                  _buildShoeGrid(newArrivalToShow),
                  const SizedBox(height: 20),
                  _sectionHeader(
                    "Recommend for you",
                    showViewAll: true,
                    isExpanded: _showAllRecommended,
                    onViewAll: () =>
                        setState(() => _showAllRecommended = !_showAllRecommended),
                  ),
                  const SizedBox(height: 10),
                  _buildShoeGrid(recommendedToShow),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        String name = "";
        String email = user?.email ?? "";
        String photoUrl = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? "";
          email = data['email'] ?? email;
          photoUrl = data['profileUrl'] ?? "";
        }

        ImageProvider profileImage;

        if (photoUrl.isNotEmpty) {
          if (photoUrl.startsWith("assets/")) {
            profileImage = AssetImage(photoUrl);
          } else {
            profileImage = NetworkImage(photoUrl);
          }
        } else {
          profileImage = const AssetImage("assets/user/profile.jpeg");
        }

        return Row(
          children: [
            GestureDetector(
              onTap: widget.onProfileTap, // <-- call MainScreen callback
              child: CircleAvatar(
                radius: 22,
                backgroundImage: profileImage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: widget.onProfileTap, // <-- call MainScreen callback
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text("Welcome back",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            _shoppingBagIcon(user?.uid ?? ""),
          ],
        );
      },
    );
  }

  Widget _shoppingBagIcon(String uid) {
  return StreamBuilder<QuerySnapshot>(
    // Listening to the sub-collection 'items' inside the user's cart document
    stream: FirebaseFirestore.instance
        .collection('cart')
        .doc(uid)
        .collection('items')
        .snapshots(),
    builder: (context, snapshot) {
      int cartCount = 0;
      
      if (snapshot.hasData) {
        // The count is the number of documents in the 'items' sub-collection
        cartCount = snapshot.data!.docs.length;
      }

      return Stack(
        clipBehavior: Clip.none, // Allows the badge to sit slightly outside the box
        children: [
          _iconBtn(
            Icons.shopping_bag_outlined,
            onTap: widget.onCartTap,
          ),
          if (cartCount > 0)
            Positioned(
              right: -2, // Adjusted for better visibility
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5), // Adds a clean outline
                ),
                child: Center(
                  child: Text(
                    cartCount.toString(),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  SearchScreen(favoritelist: widget.favoritelist, onAddToFavoritelist: widget.onAddToFavoritelist)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              "Search by brand, type, style...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return CategoryItem(
            categories[index],
            isSelected: isSelected,
            onTap: () => setState(() {
              _selectedCategoryIndex = isSelected ? null : index;
            }),
          );
        },
      ),
    );
  }

  GridView _buildShoeGrid(List<Shoe> shoes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shoes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final shoe = shoes[index];
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
            onFavorite: () => toggleFavorite(shoe),
            isFavorite: shoe.isFavorite,
          ),
        );
      },
    );
  }

  static Widget _iconBtn(IconData icon,
      {Color color = Colors.black, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _sectionHeader(String title,
      {bool showViewAll = false, VoidCallback? onViewAll, bool isExpanded = false}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        if (showViewAll) ...[
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              isExpanded ? "Hide" : "View all",
              style: const TextStyle(
                color: Color.fromARGB(255, 28, 97, 201),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}