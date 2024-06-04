import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const WButton({Key? key, required this.text,
  required this.onTap}) 
  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 249, 188, 24), 
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .center, // Align children to the center horizontally
          children: [
            Center(
              // Wrap Text with Center widget
              child: Text(
                text,
                style: GoogleFonts.yatraOne(
                  fontSize: 20.0,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}