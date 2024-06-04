import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:swadilosansar_mobile/components/categorybutton.dart';
import 'package:swadilosansar_mobile/components/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketplacePage extends StatefulWidget {
  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  List<String> categories = [
    'Momo',
    'Sekuwa',
    'Noodles',
    'Acchar',
    'Nepali Set',
    'Sel Roti',
    'Chatamari',
    'Offers'
  ];
  List<dynamic> menuItems = [];
  late String accessToken;
  List<dynamic> cart = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch all items initially
  }

  Future<void> fetchData({String? category}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString('accessToken') ?? '';

      String url = 'http://10.0.2.2:8000/all/products_app/';
      if (category != null) {
        url += '?category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          menuItems = jsonDecode(response.body);
        });
      } else {
        // Handle error if request fails
        print('Failed to fetch menu items: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network errors
      print('Failed to fetch menu items: $error');
    }
  }

  void addToCart(dynamic menuItem, int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString('accessToken') ?? '';

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/cart/add/'),
        headers: <String, String>{
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'food_item_id': menuItem['id'],
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200) {
        // Item added to cart successfully
        setState(() {
          cart.add(menuItem);
        });
        print('Added to cart: ${menuItem['title']}');
      } else {
        // Failed to add item to cart
        print('Failed to add item to cart.');
      }
    } catch (error) {
      // Handle network errors
      print('Failed to add item to cart: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'स्वाडिलो - संसार',
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'नमस्ते',
                        style: GoogleFonts.yatraOne(
                          fontSize: 21.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Welcome To स्वाडिलो - संसार!',
                        style: GoogleFonts.yatraOne(
                          fontSize: 21.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/food_delivery.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 25),
              Container(
                height: 55,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories
                      .map((category) => CategoryButton(
                            categoryName: category,
                            onPressed: () {
                              fetchData(category: category.toLowerCase());
                            },
                          ))
                      .toList(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 450,
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 255, 255, 255)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final menuItem = menuItems[index];
                    return Column(
                      children: [
                        ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: Container(
                            width: 100, // Adjust the width as needed
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                menuItem['image'], // Assuming the image URL is provided in the 'image' key
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title:
                              Text(menuItem['title'] ?? 'Title not available'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(menuItem['description'] ??
                                  'Description not available'),
                              SizedBox(height: 4),
                              Text(
                                'रू${menuItem['price'] ?? 'Price not available'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                                                SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                int selectedQuantity = 1; // Default quantity
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: Text('Select Quantity'),
                                      content: DropdownButton<int>(
                                        value: selectedQuantity,
                                        onChanged: (int? value) {
                                          if (value != null) {
                                            setState(() {
                                              selectedQuantity = value;
                                            });
                                          }
                                        },
                                        items: List.generate(
                                          10,
                                          (index) => DropdownMenuItem<int>(
                                            value: index + 1,
                                            child: Text((index + 1).toString()),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            addToCart(
                                                menuItem, selectedQuantity);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Add to Cart'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: Text('Add to Cart'),
                        ),
                        Divider(
                          color: Colors.black,
                          thickness: 1,
                          height: 0,
                          indent: 16,
                          endIndent: 16,
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 25),
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
        selectedItemColor:
            Color.fromARGB(255, 249, 188, 24), // Color of selected item
        unselectedItemColor: Colors.grey, // Color of unselected items
        backgroundColor: Color.fromARGB(255, 249, 188, 24),
        iconSize: 30, // Background color of bottom navigation bar

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

