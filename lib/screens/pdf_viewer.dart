import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewer extends StatelessWidget {
  String pdfPath;
  PdfViewer({super.key, required this.pdfPath});

  // static method for navigation
  static navigate(context, String pdfPath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PdfViewer(
          pdfPath: pdfPath,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0, 1.0);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // show name of the pdf file on the app bar
        title: Text(
          pdfPath.split('/').last,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: PDFView(
        filePath: pdfPath,
      ),
    );
  }
}
