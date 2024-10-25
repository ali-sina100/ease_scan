import 'package:flutter/material.dart';
import 'my_themes.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false; // Initial theme state

  // Getter to check if the dark mode is enabled
  bool get isDarkMode => _isDarkMode;

  // Getter to get the current theme data
  ThemeData get themeData =>
      _isDarkMode ? MyThemes.darkTheme : MyThemes.lightTheme;

  // Method to toggle the theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notify all listeners to rebuild the UI
  }
}
