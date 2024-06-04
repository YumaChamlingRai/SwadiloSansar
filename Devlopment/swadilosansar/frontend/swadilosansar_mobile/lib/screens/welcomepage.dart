// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swadilosansar_mobile/components/button.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Wrap the Column with Center widget
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center everything vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center everything horizontally

            children: [
              const SizedBox(height: 0),
              // App name
              const SizedBox(
                  height: 20), // Add some spacing between the text lines
              Text(
                "Bringing Authenticity To You",
                style: GoogleFonts.yatraOne(
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),

              //Logo
              const SizedBox(height: 40), // Add space above the image
              Image.asset('assets/images/first_logo.png'),
              //subtitle
              const SizedBox(
                  height: 40), // Add some spacing between the text lines
              Text(
                "Dine The Finest",
                style: GoogleFonts.yatraOne(
                  fontSize: 25.0,
                  color: Colors.black,
                ),
              ),

              //button
              const SizedBox(height: 50), // Add space above the image
              WButton(
                  text: "Login",
                  onTap: () {
                    //go to login lage
                    Navigator.pushNamed(context, '/loginpage');
                  })
            ],
          ),
        ),
      ),
    );
  }
}
