import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'features/features.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialized the Firebase app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  
  );

  runApp(
    
    MultiProvider(
      providers: [
        // Provider for authentication
        ChangeNotifierProvider(
          create: (context) => AuthenticationProvider(),
        )
      ],
      child: const App(),
    ),
  );
}
