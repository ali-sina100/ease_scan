// // this class contains themes for the app
// import 'package:flutter/material.dart';

// class MyThemes {
//   static ThemeData dark_theme = ThemeData(
//     colorScheme:
//         const ColorScheme.dark(surface: Colors.black, primary: Colors.blue),
//   );

//   static ThemeData light_theme =
//       ThemeData(colorScheme: const ColorScheme.light(primary: Colors.blue,));

  
// }



// this class contains themes for the app
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyThemes {
   static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme:ColorScheme.fromSeed(seedColor: Colors.purple,
    brightness: Brightness.dark),
    
       textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
      // ···
      titleLarge: GoogleFonts.oswald(
        fontSize: 30,
        fontStyle: FontStyle.italic,
      ),
      bodyMedium: GoogleFonts.merriweather(),
      displaySmall: GoogleFonts.pacifico(),
    ),
  );
   static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme:ColorScheme.fromSeed(seedColor: Colors.purple,
    brightness: Brightness.light),
    
       textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold, // Set the text color here for titleLarge
      ),
      // ···
      titleLarge: GoogleFonts.oswald(
        fontSize: 30,
        fontStyle: FontStyle.italic,
      ),
      bodyMedium: GoogleFonts.merriweather(),
      displaySmall: GoogleFonts.pacifico(),
    ),
  );
}
