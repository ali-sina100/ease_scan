
import 'package:ease_scan/features/Authentication/pages/login_page.dart';
import 'package:ease_scan/features/Authentication/provider/authetication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/screens.dart';
import 'themes/theme_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authProvider =
        Provider.of<AuthenticationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: authProvider.isUserSignedIn()
          ? authProvider.isUserVerified()
              ? const HomeScreen()
              : const EmailVerificationScreen()
          : LoginPage(),
    );
  }
}
