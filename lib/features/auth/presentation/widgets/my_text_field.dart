
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hText;
  final TextEditingController controller;
  final bool obscureText;
  const MyTextField({super.key, required this.hText, required this.controller,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hText,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:const  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}
