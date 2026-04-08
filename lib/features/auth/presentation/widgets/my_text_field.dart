import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hText;
  final TextEditingController controller;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final Icon icon;
  const MyTextField({super.key, required this.hText, required this.controller,
    this.obscureText =false, required this.validator, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      validator: validator,
      decoration: InputDecoration(
        suffixIcon: icon,
        hintText: hText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey[200],
        //fillColor: Colors.white.withOpacity(0.9),
        contentPadding:const  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder:OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 3,),
        ),
      ),
    );
  }
}
