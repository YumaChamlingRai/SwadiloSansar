import 'package:flutter/material.dart';
import 'package:swadilosansar_mobile/screens/changepw.dart';
import 'package:swadilosansar_mobile/screens/feedbacks.dart';
import 'package:swadilosansar_mobile/screens/login.dart';
import 'package:swadilosansar_mobile/screens/welcomepage.dart';
import 'package:swadilosansar_mobile/screens/market_page.dart';
import 'package:swadilosansar_mobile/screens/register.dart';
import 'package:swadilosansar_mobile/screens/profile.dart';
import 'package:swadilosansar_mobile/screens/cart.dart';
import 'package:swadilosansar_mobile/screens/orders.dart';
import 'package:swadilosansar_mobile/screens/table.dart';


class Routes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/welcomepage': (context) => const WelcomePage(),
      '/loginpage': (context) => const LoginPage(),
      '/marketpage': (context) => MarketplacePage(),
      '/register': (context) => const SignUpPage(),
      '/profile': (context) => const ProfilePage(),
      '/cart': (context) => const CartPage(),
      '/feed': (context) => FeedbackPage(),
      '/booktable': (context) => const BookTable(),
      '/pwchange': (context) => const ChangePasswordPage(),
       '/order': (context) => const OrderPage(),
    };
  }
}
