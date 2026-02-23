import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CategoryScreen(),
  ));
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Brand',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: const [
          CategoryCard(
            title: 'Air Jordan',
            imageUrl: 'assets/shoes/shoe1.png', // Replace with your local asset
          ),
          SizedBox(height: 20),
          CategoryCard(
            title: 'Life Style',
            imageUrl: 'assets/shoes/shoe2.png', // Replace with your local asset
          ),
          SizedBox(height: 20),
          CategoryCard(
            title: 'Vintage',
            imageUrl: 'assets/shoes/shoe3.png',
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const CategoryCard({super.key, required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none, // Allows the shoe to pop out
        children: [
          // The Grey Background Card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6F9),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // The Floating Shoe Image
          Positioned(
            right: -10,
            top: -20,
            bottom: -20,
            child: Transform.rotate(
              angle: -0.2, // Slight tilt like the image
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                width: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class CustomBottomNav extends StatelessWidget {
//   const CustomBottomNav({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
//       child: Container(
//         height: 70,
//         decoration: BoxDecoration(
//           color: const Color(0xFF1A1A1A),
//           borderRadius: BorderRadius.circular(35),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             const Icon(Icons.home_outlined, color: Colors.white, size: 28),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.grid_view_rounded, color: Colors.black, size: 20),
//                   SizedBox(width: 8),
//                   Text('CATEGORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//                 ],
//               ),
//             ),
//             const Icon(Icons.favorite_border, color: Colors.white, size: 28),
//             const Icon(Icons.person_outline, color: Colors.white, size: 28),
//           ],
//         ),
//       ),
//     );
//   }
// }