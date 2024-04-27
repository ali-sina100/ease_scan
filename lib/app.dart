import 'package:flutter/material.dart';
import './screens/screens.dart';
import './themes/themes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyThemes.light_theme,
      darkTheme: MyThemes.dark_theme,
      
      home: SplashScreen(),
    );
  }
}
