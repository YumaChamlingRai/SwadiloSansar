import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final double height;

  const RegButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.height = 50.0, required MaterialColor color, // Default height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 15), // Add space above the image
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 150,
              height: 55.0, // Adjusted height
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 249, 188, 24),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  text,
                  style: GoogleFonts.yatraOne(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
