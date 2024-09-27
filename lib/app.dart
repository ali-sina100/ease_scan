import 'package:ease_scan/features/Authentication/pages/login_page.dart';
import 'package:ease_scan/features/Authentication/provider/authetication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/screens.dart';
import './themes/themes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    AuthenticationProvider authProvider =
        Provider.of<AuthenticationProvider>(context);

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: MyThemes.light_theme,

      darkTheme: MyThemes.dark_theme,

      themeMode: ThemeMode.light,

      home: authProvider.isUserSignedIn()

          ? authProvider.isUserVerified()

              ? HomeScreen()

              : const EmailVerificationScreen()

          : LoginPage(),

    );

  }
  
}
