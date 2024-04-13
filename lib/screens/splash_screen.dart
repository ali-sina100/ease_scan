import 'package:ease_scan/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../utilities/utilities.dart';
import 'screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loading = true;
  late bool permissions_granted = false;

  @override
  void initState() {
    checkPermission();
    super.initState();
  }

  checkPermission() async {
    await MyPermissionHandler.checkPermissions().then(
      (value) => {
        if (value) {permissions_granted = value},
        setState(() {
          loading = false;
        })
      },
    );
  }

  requestPermission() async {
    await MyPermissionHandler.requestPermission().then((value) {
      setState(() {
        permissions_granted = value;
      });
    });
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : permissions_granted
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                          "Thank you for giving us access to storage and camera"),
                      TextButton(
                        // Navigate to home screen when "continue" button clicked
                        onPressed: () => {HomeScreen.navigate(context)},
                        child: const Text("continue"),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("We need permission to camera and storage"),
                      TextButton(
                        onPressed: () => {requestPermission()},
                        child: const Text("Give permission"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
