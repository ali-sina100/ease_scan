import 'package:flutter/material.dart';
import '../utilities/utilities.dart';
import 'screens.dart';
import '../features/features.dart';

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
          LoginPage.navigate(context);

          loading = false;
        })
      },
    );
  }

  requestPermission() async {
    await MyPermissionHandler.requestPermission().then((value) {
      //Check if the permission granted then navigate to other page
      if (value) {
        LoginPage.navigate(context);
      }
    });
  }

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
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
