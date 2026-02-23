import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shoe_shop/screens/cart_screen.dart';
import 'package:shoe_shop/screens/favoritelist_screen.dart';
import 'package:shoe_shop/screens/homepage.dart';
import 'package:shoe_shop/screens/profile_screen.dart';
import '../widgets/app_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final String uid;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    uid = user?.uid ?? "default_user_id";

    _pages = [
      HomePage(
        favoritelist: const [],
        onAddToFavoritelist: (_) {},
        onProfileTap: () => _goToProfile(),
        onCartTap: () => _goToCart(),
      ), // index 0 -> Home
      FavoritelistScreen(uid: uid), // index 1 -> Favorite
      ShoppingCartScreen(uid: uid), // index 2 -> Cart
      const ProfileScreen(), // index 3 -> Profile
    ];
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _goToProfile() {
    setState(() {
      _selectedIndex = 3;
    });
  }

  void _goToCart() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomNav(
        index: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}