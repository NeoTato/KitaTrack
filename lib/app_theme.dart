import 'package:flutter/material.dart';

class AppTheme {
  // App Colors
  static const Color creamBackground = Color(0xFFFEF7EA);
  static const Color primaryOrange = Color(0xFFFF6D00);
  static const Color brownText = Colors.brown;
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: brownText,
  );

  static TextStyle subHeadingStyle = TextStyle(
    fontSize: 14,
    color: Colors.deepOrange[800],
  );

  static TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.grey[700],
  );

  // Input Decoration Theme
  static InputDecoration inputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      
      // Default Border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      
      // Focused Border
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black),
      ),
      
      // Error Border (Red Highlight)
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      
      // Focused Error Border (Thicker Red)
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      
      // Error Text Style
      errorStyle: const TextStyle(color: Colors.red, fontSize: 12),

      filled: true,
      fillColor: Colors.white,
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: primaryOrange,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );

  static ButtonStyle googleButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0,
    side: BorderSide(color: Colors.grey.shade300),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}