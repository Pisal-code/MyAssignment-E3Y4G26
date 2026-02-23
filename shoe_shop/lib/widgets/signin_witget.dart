import 'package:flutter/material.dart';

Widget buildSocialButton(IconData icon) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white30),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.all(10),
    child: Icon(icon, color: Colors.white),
  );
}

Widget buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  bool isPassword = false,
  bool isPasswordVisible = false,
  VoidCallback? togglePassword,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword && !isPasswordVisible,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: togglePassword,
            )
          : null,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
