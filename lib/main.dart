import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/features.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) => AuthenticationProvider(),
        )
      ],
      child: const App(),
    ),
  );
}
