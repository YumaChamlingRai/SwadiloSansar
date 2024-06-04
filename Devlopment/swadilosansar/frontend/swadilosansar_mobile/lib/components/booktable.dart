import 'package:flutter/material.dart';

class BookTableBtn extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const BookTableBtn({
    Key? key,
    required this.text,
    this.color = const Color.fromARGB(255, 186, 141, 14), // Default color is green
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(color), // Set button color
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Button border radius
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white, // Text color is white
          fontSize: 16,
        ),
      ),
    );
  }
}
