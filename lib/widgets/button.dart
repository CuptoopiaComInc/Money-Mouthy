import 'package:flutter/material.dart';

class PurpleButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onPressed; // Function to handle button press
  final double? width; // Optional width parameter
  final double height; // Height parameter with default
  final double fontSize; // Font size with default
  
  const PurpleButton({
    Key? key,
    required this.buttonText,
    this.onPressed,
    this.width,
    this.height = 50,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {}, // Use provided callback or empty function
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5159FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: Size(width ?? double.infinity, height),
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}