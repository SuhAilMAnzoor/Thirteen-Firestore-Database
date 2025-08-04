import 'package:flutter/material.dart';

class ButtonStyles {
  static final ButtonStyle primaryButtonStyle = ButtonStyle(
    backgroundColor: WidgetStateProperty.all<Color>(
      const Color.fromARGB(255, 155, 127, 3),
    ),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    overlayColor: WidgetStateProperty.all<Color>(
      const Color.fromARGB(255, 43, 14, 171).withOpacity(0.1),
    ),
    elevation: WidgetStateProperty.all<double>(8.0),
    padding: WidgetStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    ),
    shape: WidgetStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
    textStyle: WidgetStateProperty.all<TextStyle>(
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
