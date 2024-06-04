import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swadilosansar_mobile/components/loginbutton.dart';
import 'package:swadilosansar_mobile/components/signupbutton.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key});

  Future<void> loginUser(
      BuildContext context, String email, String password) async {
    print('Email: $email');
    print('Password: $password');
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/user/login/'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'role': 'customer', // Hardcoded role as 'customer'
        }),
      );

      print('Response Data: ${response.body}');

      if (response.statusCode == 200) {
        // Save tokens upon successful login
        final responseData = jsonDecode(response.body);
        final refreshToken = responseData['refresh'];
        final accessToken = responseData['access'];
        final role = responseData['role'];
        await saveTokens(refreshToken, accessToken, role);

        // Navigate to appropriate page
        Navigator.pushNamed(context, '/marketpage');
      } else {
        final snackBar = SnackBar(
          content: Text('Login Failed'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> saveTokens(
      String refreshToken, String accessToken, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('role', role);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  @override
  Widget build(BuildContext context) {
    String email = '';
    String password = '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 65),
                Image.asset(
                  'assets/images/first_logo.png',
                  width: 75,
                  height: 95,
                ),
                SizedBox(height: 20),
                Text(
                  "Welcome To स्वाडिलो - संसार",
                  style: GoogleFonts.yatraOne(
                    fontSize: 21.0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (value) => email = value,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      labelText: 'Enter Your Email',
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (value) => password = value,
                    obscureText: true,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      labelText: 'Enter Your Password',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                LoginButton(
                  text: "Login",
                  onTap: () {
                    loginUser(context, email, password);
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        height: 50,
                        thickness: 0.5,
                        color: Colors.black,
                        indent: 30,
                        endIndent: 10,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Or",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        height: 50,
                        thickness: 0.5,
                        color: Colors.black,
                        indent: 10,
                        endIndent: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  "Don't Have an Account? Sign Up",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                SignUpButton(
                  text: "Sign Up",
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
