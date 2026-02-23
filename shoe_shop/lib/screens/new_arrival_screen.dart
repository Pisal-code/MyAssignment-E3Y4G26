import 'package:flutter/material.dart';
import '../models/shoe.dart';

class ShoeGridCard extends StatelessWidget {
  final Shoe shoe;
  final VoidCallback? onTap; // optional tap callback

  const ShoeGridCard({super.key, required this.shoe, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // triggers navigation if provided
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shoe Image + Best Selling Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    shoe.imageUrl != null
                        ? "assets/shoes/${shoe.imageUrl!}"
                        : "",
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                if (shoe.bestSelling)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Best Selling',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Shoe Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                shoe.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Price & Old Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    "\$${shoe.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (shoe.oldPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        "\$${shoe.oldPrice!.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Stock & Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Stock: ${shoe.stock}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                shoe.status,
                style: TextStyle(
                  fontSize: 12,
                  color: shoe.status.toLowerCase() == 'active'
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
