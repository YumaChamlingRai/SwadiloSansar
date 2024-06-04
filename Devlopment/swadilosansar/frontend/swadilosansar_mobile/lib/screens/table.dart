import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:swadilosansar_mobile/components/booktable.dart';

class BookTable extends StatelessWidget {
  const BookTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Declare variables to hold the selected branch and number of people
    String selectedBranch = 'Branch A'; // Initialize with a default value
    String time = ''; // Initialize empty
    String numberOfPeople = ''; // Initialize empty

    // Function to handle booking a table
    // Function to handle booking a table
Future<void> bookTable(Map<String, String> reservationData) async {
  String url = 'http://10.0.2.2:8000/book/';

  // Retrieve authentication token from shared preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken'); // Replace with the actual key

  if (accessToken == null) {
    print('No auth token found. User might not be logged in.');
    return;
  }

  // Convert reservation data to JSON format
  String requestBody = json.encode(reservationData);

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // Note 'Bearer' prefix for JWT
      },
      body: requestBody,
    );

    // Check if the request was successful (status code 201)
    if (response.statusCode == 201) {
      // Handle successful reservation
      print('Table reservation request sent!');
      // You can navigate to another screen or show a success message
    } else {
      // Handle errors
      print('Failed to reserve table. Error: ${response.body}');
      // You can show an error message to the user
    }
  } catch (error) {
    // Handle errors from the HTTP request
    print('Error occurred while reserving table: $error');
    // You can show an error message to the user
  }
}


    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0), // Add padding at the top
          child: Center(
            // Wrap Column with Center widget
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Align children to the center horizontally
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Align children to the center horizontally
                  children: [
                    Image.asset(
                      'assets/images/first_logo.png', // Assuming you have a logo for the restaurant
                      width: 75,
                      height: 95,
                    ),
                    const SizedBox(width: 10), // Add some spacing between the image and the text
                    Text(
                      "Book a Table",
                      style: GoogleFonts.yatraOne(
                        fontSize: 21.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                // Time TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (value) {
                      time = value; // Update the time variable as the user types
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Branch Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField(
                    value: selectedBranch,
                    onChanged: (String? value) {
                      if (value != null) {
                        selectedBranch = value;
                      }
                    },
                    items: ['Branch A', 'Branch B'].map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Branch',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // People count TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (value) {
                      numberOfPeople = value; // Update the numberOfPeople variable as the user types
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Number of People',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Reserve Table button
                BookTableBtn(
                  text: "Reserve Table",
                  onTap: () {
                    // Prepare reservation data
                    Map<String, String> reservationData = {
                      'branch': selectedBranch,
                      'time': time,
                      'number_of_people': numberOfPeople,
                    };
                    // Call function to book table
                    bookTable(reservationData);
                  },
                ),
              ],
            ),
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
        selectedItemColor:
            Color.fromARGB(255, 249, 188, 24), // Color of selected item
        unselectedItemColor: Colors.grey, // Color of unselected items
        backgroundColor: Color.fromARGB(255, 249, 188, 24),
        iconSize: 30, 
        
        // Handle navigation based on the index
        onTap: (index) {
          // Handle navigation based on the index
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/cart');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/orders');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
