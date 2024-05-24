import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utilities/utilities.dart';
import '../features/features.dart';
import 'screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool loading = true;
  late bool permissions_granted = false;
  late AuthenticationProvider _authenticationProvider;
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
          _authenticationProvider.isUserSignedIn()
              ? HomeScreen.navigate(context)
              : LoginPage.navigate(context);
          loading = false;
        })
      },
    );
  }

  requestPermission() async {
    await MyPermissionHandler.requestPermission().then((value) {
      //Check if the permission granted then navigate to other page
      if (value) {
        _authenticationProvider.isUserSignedIn()
            ? HomeScreen.navigate(context)
            : LoginPage.navigate(context);

        LoginPage.navigate(context);
      }
    });
  }

  @override
  Scaffold build(BuildContext context) {
    _authenticationProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);

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
