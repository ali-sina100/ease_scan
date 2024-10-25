// This file contains code for setting screen to change the default theme and default filter.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  // static method to navigate to this screen with slide animation
  static navigate(context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutQuart;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            // List tile for switching theme
            // List tile for switching theme
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),

            // List tile for changing filter
            ListTile(
              title: const Text('Default Filter'),
              // trailing with drop down and list of filters
              trailing: DropdownButton<String>(
                value: 'Default',
                onChanged: (String? newValue) {
                  //TODO
                },
                items: <String>['Default', 'Filter 1', 'Filter 2', 'Filter 3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              onTap: () {
                //TODO
              },
            ),

            // list tile to change the font size
            ListTile(
              title: const Text('Font size'),
              // trailing with drop down and list of font sizes
              trailing: DropdownButton<String>(
                value: 'Default',
                onChanged: (String? newValue) {
                  //TODO
                },
                items: <String>['Default', 'Small', 'Medium', 'Large']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              onTap: () {
                //TODO
              },
            ),
          ],
        ),
      ),
    );
  }
}
