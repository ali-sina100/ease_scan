import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportPage extends StatelessWidget {
  late img.Image image;
  PdfExportPage({required this.image, super.key});

  // static method for navigation
  static navigate(context, img.Image image) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PdfExportPage(
          image: image,
        ),
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

  final pdfDoc = pw.Document();

  Future<void> _createPdf() async {
    pdfDoc.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(child: pw.Image(pw.MemoryImage(image.getBytes())));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _createPdf(),
        builder: (context, snapshot) {
          // check if pdf is being created
          if (snapshot.connectionState == ConnectionState.done) {
            return Image.memory(image.data!.getBytes());
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
