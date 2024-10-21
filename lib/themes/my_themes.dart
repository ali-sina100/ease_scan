// this class contains themes for the app
import 'package:flutter/material.dart';

class MyThemes {
  static ThemeData dark_theme = ThemeData(
    colorScheme:
        const ColorScheme.dark(surface: Colors.black, primary: Colors.white),
  );

  static ThemeData light_theme =
      ThemeData(colorScheme: const ColorScheme.light(primary: Colors.blue,));

  
}
