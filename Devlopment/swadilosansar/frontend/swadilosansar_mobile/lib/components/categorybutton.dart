import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryButton extends StatelessWidget {
  final String categoryName;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onPressed; // Add the onPressed callback

  const CategoryButton({
    required this.categoryName,
    this.borderColor = const Color.fromARGB(255, 249, 188, 24),
    this.textColor = const Color.fromARGB(255, 2, 0, 0),
    required this.onPressed, // Require the onPressed callback
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed, // Use the provided onPressed callback
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double>(4.0),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: borderColor, width: 2.0),
          ),
        ),
        child: Text(
          categoryName,
          style: GoogleFonts.yatraOne(
            textStyle: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w200,
            ),
          ),
        ),
      ),
    );
  }
}
