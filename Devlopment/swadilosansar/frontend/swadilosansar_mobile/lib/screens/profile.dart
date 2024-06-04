import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? name;
  String? email;
  String? phone_number;
  String? address;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        // Handle the case where the access token is not available
        print('Access token is missing');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/user/profile/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          name = userData['name'];
          email = userData['email'];
          phone_number = userData['phone_number'];
          address = userData['address'];
        });
      } else {
        // Handle error response
        print('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      print('Error fetching user profile: $e');
    }
  }

  Future<void> logoutUser(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    final accessToken = prefs.getString('accessToken'); // Fetch access token

    if (refreshToken == null || accessToken == null) {
      // Handle the case where the tokens are not available
      print('Tokens are missing');
      return;
    }

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/user/logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Use access token for authorization
      },
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      // Clear tokens from SharedPreferences
      await prefs.remove('refreshToken');
      await prefs.remove('accessToken');
      await prefs.remove('role');

      // Show logout successful message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout successful'),
        ),
      );

      // Navigate to welcome page
      Navigator.pushReplacementNamed(context, '/welcomepage');
    } else if (response.statusCode == 400) {
      // Token is already blacklisted or invalid
      // Clear tokens from SharedPreferences and navigate to welcome page
      await prefs.remove('refreshToken');
      await prefs.remove('accessToken');
      await prefs.remove('role');

      // Show logout successful message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout successful'),
        ),
      );

      Navigator.pushReplacementNamed(context, '/welcomepage');
    } else {
      // Handle other error responses
      print('Failed to logout: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    // Handle network error
    print('Error logging out: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/first_logo.png',
                  width: 75,
                  height: 95,
                ),
              ),
              const SizedBox(height: 20),
              // Display Name
              if (name != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person),
                    const SizedBox(width: 10),
                    Text(
                      name!,
                      style: GoogleFonts.yatraOne(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              // Display Email
              if (email != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email),
                    const SizedBox(width: 10),
                    Text(
                      email!,
                      style: GoogleFonts.yatraOne(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
              // Display Phone Number
              if (phone_number != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone),
                    const SizedBox(width: 10),
                    Text(
                      phone_number!,
                      style: GoogleFonts.yatraOne(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              // Display Location
              if (address != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_city),
                    const SizedBox(width: 10),
                    Text(
                      address!,
                      style: GoogleFonts.yatraOne(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              Container(
                width: double.infinity,
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Explore More",
                  style: GoogleFonts.yatraOne(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 249, 188, 24), // Set text color
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Navigate to Reserve Table
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/booktable');
                  // Handle navigation to Reserve Table
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.table_chart),
                    const SizedBox(width: 10),
                    Text(
                      "Reserve Table",
                      style: GoogleFonts.yatraOne(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Navigate to Change Password
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/pwchange');
                  // Handle navigation to Change Password
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.lock),
                    const SizedBox(width: 10),
                    Text(
                      "Change Password",
                      style: GoogleFonts.yatraOne(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
// Navigate to Feedback
              InkWell(
                onTap: () {
                  // Handle navigation to Feedback
                   Navigator.pushNamed(context, '/feed');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.feedback), // Icon for Feedback
                    const SizedBox(width: 10),
                    Text(
                      "Feedback",
                      style: GoogleFonts.yatraOne(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              // Navigate to Sign Out
              InkWell(
                onTap: () {
                  logoutUser(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    const SizedBox(width: 10),
                    Text(
                      'Sign Out',
                      style: GoogleFonts.yatraOne(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'My Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        selectedItemColor: Color.fromARGB(255, 249, 188, 24),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color.fromARGB(255, 249, 188, 24),
        iconSize: 30,
        onTap: (index) {
          // Handle navigation based on the index
          if (index == 0) {
            Navigator.pushNamed(context, '/marketpage');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/cart');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/order');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
