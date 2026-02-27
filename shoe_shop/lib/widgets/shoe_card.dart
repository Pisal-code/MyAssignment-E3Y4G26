import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shoe.dart';
import '../providers/favorite_provider.dart';
import '../screens/shoe_detail_screen.dart';

class ShoeCard extends StatelessWidget {
  final Shoe shoe;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;
  final bool isFavoritelistMode;

  const ShoeCard({
    super.key,
    required this.shoe,
    this.onFavorite,
    this.onDelete,
    this.isFavoritelistMode = false,
    required bool isFavorite,
  });

  String? getImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith("http") || url.startsWith("assets/shoes")) {
      return url;
    }
    return "assets/shoes/$url";
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = getImage(shoe.imageUrl);

    // ===============================
    // ✅ FAVORITE LIST MODE (HORIZONTAL)
    // ===============================
    if (isFavoritelistMode) {
      return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 3),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: imagePath != null
                  ? imagePath.startsWith("http")
                      ? Image.network(imagePath, fit: BoxFit.cover)
                      : Image.asset(imagePath, fit: BoxFit.cover)
                  : const Icon(Icons.broken_image, size: 50),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shoe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "\$${shoe.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (shoe.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          "\$${shoe.oldPrice!.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
          ],
        ),
      );
    }

    // ===============================
    // ✅ GRID MODE (HOME PAGE)
    // ===============================
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShoeDetailScreen(shoe: shoe, onFavorite: () {}),
          ),
        );
      },
      child: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          final isFav = favoriteProvider.isFavorite(shoe.id);
          
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      offset: Offset(0, 3),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: imagePath != null
                            ? imagePath.startsWith("http")
                                ? Image.network(imagePath, fit: BoxFit.contain)
                                : Image.asset(imagePath, fit: BoxFit.contain)
                            : const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shoe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "\$${shoe.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (shoe.oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "\$${shoe.oldPrice!.toStringAsFixed(2)}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ❤️ Favorite Button
              if (onFavorite != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black,
                      size: 20,
                    ),
                    onPressed: () async {
                      await favoriteProvider.toggleFavorite(shoe);
                      if (onFavorite != null) {
                        onFavorite!();
                      }
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

