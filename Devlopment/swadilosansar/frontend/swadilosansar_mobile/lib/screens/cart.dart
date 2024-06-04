import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = [];
  String _selectedBranch = 'Branch A';
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/cart/view/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            cartItems = jsonDecode(response.body)['items'] ?? [];
            calculateTotalAmount();
          });
        } else {
          print('Failed to fetch cart items: ${response.statusCode}');
        }
      } else {
        print('Access token is null or empty');
      }
    } catch (error) {
      print('Failed to fetch cart items: $error');
    }
  }

  void calculateTotalAmount() {
    totalAmount = cartItems.fold(0, (previousValue, item) {
      final price = item['food_item']['price'] ?? 0;
      final quantity = item['quantity'] ?? 0;
      return previousValue + (price * quantity);
    });
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        final response = await http.delete(
          Uri.parse('http://10.0.2.2:8000/cart/remove/$itemId/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 204) {
          // Item removed successfully
          fetchCartItems(); // Refresh cart items after removal
        } else {
          print('Failed to remove item from cart: ${response.statusCode}');
        }
      } else {
        print('Access token is null or empty');
      }
    } catch (error) {
      print('Failed to remove item from cart: $error');
    }
  }

  Future<void> confirmOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/give-order/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'payment_method': 'Cash on Delivery',
            'paid_amount': totalAmount,
          }),
        );

        if (response.statusCode == 201) {
          // Order placed successfully
          // Navigate to success page or display success message
          print('Order placed successfully.');
        } else {
          print('Failed to place order: ${response.statusCode}');
        }
      } else {
        print('Access token is null or empty');
      }
    } catch (error) {
      print('Failed to place order: $error');
    }
  }

  void initiateKhaltiPayment() {
    KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: (totalAmount * 100).toInt(), // Amount in paisa
        productIdentity: 'product-id',
        productName: 'Food Items',
        productUrl: 'http://10.0.2.2:8000/cart/view/',
      ),
      preferences: [
        PaymentPreference.khalti,
        PaymentPreference.eBanking,
        PaymentPreference.mobileBanking,
        PaymentPreference.connectIPS,
        PaymentPreference.sct,
      ],
      onSuccess: (success) {
        print('Payment successful: $success');
        // Handle successful payment here
      },
      onFailure: (failure) {
        print('Payment failed: $failure');
        // Handle failed payment here
      },
      onCancel: () {
        print('Payment cancelled.');
        // Handle payment cancellation here
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in cartItems)
              ListTile(
                title: Text(item['food_item']['title'] ?? 'No name'),
                subtitle: Text('Quantity: ${item['quantity'] ?? 0}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'रू${(item['food_item']['price'] ?? 0) * (item['quantity'] ?? 0)}'),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        removeFromCart(item['id'].toString());
                      },
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Total Amount: रू$totalAmount',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  DropdownButton<String>(
                    value: _selectedBranch,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedBranch = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'Branch A',
                        child: Text('Nakhipot Branch'),
                      ),
                      DropdownMenuItem(
                        value: 'Branch B',
                        child: Text('Dharan Branch'),
                      ),
                    ],
                  ),
                  SizedBox(
                      height: 25), // Add space between dropdowns and button
                  ElevatedButton(
                    onPressed: confirmOrder,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 0, 0, 0),
                      backgroundColor: Color.fromARGB(
                          255, 205, 163, 37), // Set text color to dark yellow
                    ),
                    child: Text('Confirm Order'),
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      payWithKhaltiInApp();
                    },
                    child: Text('Checkout'),
                  ),
                ],
              ),
            ),
          ],
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

  payWithKhaltiInApp() {
    KhaltiScope.of(context).pay(
        config: PaymentConfig(
            amount: 1000,
            productIdentity: "order_id",
            productName: "food_item"),
            preferences:[
              PaymentPreference.khalti,
              PaymentPreference.eBanking,
              PaymentPreference.mobileBanking,
              PaymentPreference.connectIPS,
              PaymentPreference.sct,
            ] ,
        onSuccess: onSuccess,
        onFailure: onFailure,
        onCancel: onCancel);
  }

  void onSuccess(PaymentSuccessModel success) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Payment Success"),
            actions: [
              SimpleDialogOption(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void onFailure(PaymentFailureModel failure) {
    debugPrint(failure.toString());
  }

  void onCancel() {
    debugPrint("Cacncel");
  }
}

