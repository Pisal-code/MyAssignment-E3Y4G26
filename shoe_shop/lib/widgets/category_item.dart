import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final double height;

  const CategoryItem(
    this.text, {
    super.key,
    required this.isSelected,
    required this.onTap,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: height,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color.fromARGB(255, 0, 0, 0)
                // ignore: deprecated_member_use
                : const Color.fromARGB(255, 0, 0, 0).withOpacity(0.8),
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                // ignore: deprecated_member_use
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}