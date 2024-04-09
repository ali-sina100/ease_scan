import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text("We need permission to camera and storage"),
            TextButton(
                onPressed: () => {}, child: const Text("Give permission")),
          ],
        ),
      ),
    );
  }
}
