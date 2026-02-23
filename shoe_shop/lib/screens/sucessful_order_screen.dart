import 'package:flutter/material.dart';
// 1. Make sure to import your MainScreen here
import 'package:shoe_shop/main_screen.dart'; 

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const AnimatedSuccessCheckmark(),
              const SizedBox(height: 32),
              const Text(
                'Order Confirmed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your order has been confirmed, delivery will soon contact you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 2. Navigate to MainScreen and remove everything else
                    // This resets the app to the Home tab with the Navigation Bar visible
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom animated checkmark widget (same as before)
class AnimatedSuccessCheckmark extends StatefulWidget {
  const AnimatedSuccessCheckmark({super.key});

  @override
  State<AnimatedSuccessCheckmark> createState() => _AnimatedSuccessCheckmarkState();
}

class _AnimatedSuccessCheckmarkState extends State<AnimatedSuccessCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFCEF5CD),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF4CD964),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }
}