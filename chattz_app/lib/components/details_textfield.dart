import 'package:flutter/material.dart';

class DetailsTextField extends StatelessWidget {
  const DetailsTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.errorStyle,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextStyle? errorStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.tealAccent,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 16, // Slightly larger font for readability
        fontWeight: FontWeight.w500, // Semi-bold for better focus
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.tealAccent,
          fontSize: 14, // Consistent sizing for label text
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors.grey[700]!), // Darker grey for enabled state
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.tealAccent, // Slightly brighter tealAccent
            width: 2, // Slightly thicker underline for focus
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 2, // Consistent thickness for error state
          ),
        ),
        errorStyle: errorStyle ??
            const TextStyle(
              color: Colors.redAccent, // Subtle error color
              fontSize: 12, // Slightly smaller for less distraction
              fontWeight: FontWeight.w400,
            ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12), // Adjust padding for better spacing
        hintText: 'Enter $label', // Provide a helpful hint
        hintStyle: TextStyle(
          color: Colors.grey[600], // Subtle hint text
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
      ),
      validator: validator,
    );
  }
}
