import 'package:flutter/material.dart';
import '../models/shoe.dart';

class ShoeGridCard extends StatelessWidget {
  final Shoe shoe;

  const ShoeGridCard({super.key, required this.shoe});

String? getImage(String? url) {
  if (url == null || url.isEmpty) return null; // no image
  if (url.startsWith("http") || url.startsWith("assets/shoes")) return url;
  return "assets/shoes/$url"; // local asset
}
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: getImage(shoe.imageUrl) != null
                      ? Image.asset(
                          getImage(shoe.imageUrl)!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.broken_image, size: 50),
                ),
                if (shoe.bestSelling)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(14),
                          topLeft: Radius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "BEST SELLING",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Icons.favorite_border),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(shoe.name,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text("\$${shoe.price.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 15)),
            if (shoe.oldPrice != null) ...[
              const SizedBox(width: 8),
              Text(
                "\$${shoe.oldPrice!.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.red,
                  decoration: TextDecoration.lineThrough,
                ),
              )
            ]
          ],
        )
      ],
    );
  }
}