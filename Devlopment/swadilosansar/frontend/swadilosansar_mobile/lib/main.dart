import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart'; // Import Khalti package
import 'package:swadilosansar_mobile/routes.dart';
import 'package:swadilosansar_mobile/screens/welcomepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KhaltiScope( // Wrap with KhaltiScope
      publicKey: 'test_public_key_eea3bdde266f4906807402d7e00b8e27',
      enabledDebugging: true, // Enable debugging for Khalti
      builder: (context, navigatorKey) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const WelcomePage(),
          routes: Routes.getRoutes(),
          navigatorKey: navigatorKey,
          localizationsDelegates: const [
            KhaltiLocalizations.delegate
          ],
        );
      },
    );
  }
}
