
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hText;
  final TextEditingController controller;
  const MyTextField({super.key, required this.hText, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
