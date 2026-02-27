import 'package:flutter/material.dart';
import 'package:shoe_shop/models/shoe.dart';
import 'package:shoe_shop/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'shoe_detail_screen.dart';

class FavoritelistScreen extends StatelessWidget {
  const FavoritelistScreen({super.key});

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
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          final favorites = favoriteProvider.favorites;

          if (favoriteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favorites.isEmpty) {
            return const Center(child: Text("Your favorite list is empty"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final shoe = favorites[index];

              return FavoriteListItem(
                shoe: shoe,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShoeDetailScreen(
                      shoe: shoe,
                      onFavorite: () {},
                    ),
                  ),
                ),
                onDelete: () async {
                  await favoriteProvider.removeFromFavorites(shoe.id);
                },
                onMoveToCart: () async {
                  // Check if shoe has a size selected
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
                      // Show message to add from shoe detail page
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please add from shoe detail")),
                        );
                      }
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
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05)
            )
          ],
        ),
        child: Row(
          children: [
            /// IMAGE
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), 
                color: const Color(0xFFF3F4F6)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: shoe.imageUrl != null && shoe.imageUrl!.startsWith('http') 
                    ? Image.network(shoe.imageUrl!, fit: BoxFit.contain)
                    : shoe.imageUrl != null 
                        ? Image.asset(shoe.imageUrl!, fit: BoxFit.contain)
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
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

                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "\$${shoe.price.toStringAsFixed(0)}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                      ),
                      if (shoe.oldPrice != null) ...[
                        const SizedBox(width: 6),
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
                  const SizedBox(height: 10),
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

