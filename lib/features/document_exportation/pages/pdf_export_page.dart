import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../utilities/file_utilities.dart';

class PdfExportPage extends StatelessWidget {
  late Uint8List image_file;
  PdfExportPage({required this.image_file, super.key});

  // static method for navigation
  static navigate(context, Uint8List jpgImage) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PdfExportPage(
          image_file: jpgImage,
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
  // path to saved Pdf file
  String pdfPath = '';
  // Function to create the pdf file
  Future<void> _createPdf() async {
    pdfDoc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(image_file)),
          );
        },
      ),
    );
    // put the saved pdf file path into the pdfPath variable
    await savePDF();
  }

  // function to save the pdf file
  Future<void> savePDF() async {
    var savedFile = await pdfDoc.save();
    List<int> fileInts = List.from(savedFile);
    pdfPath = await FileUtilities.savePDF(Uint8List.fromList(fileInts));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('PDF Export and Share'),
      ),
      body: Stack(
        children: [
          // Pdf preview
          Positioned(
            // Align the pdf preview to the center
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,

            child: FutureBuilder(
              future: _createPdf(),
              builder: (context, snapshot) {
                // check if pdf is being created
                if (snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.memory(image_file),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
          // Button bar controll buttons
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                border: Border.all(color: Colors.white, width: 0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rename button
                    Column(
                      children: [
                        // Icon
                        IconButton(
                            onPressed: () {
                              //TODO: Implement Rename pdf
                            },
                            icon: const Icon(Icons.edit_rounded)),
                        // Label
                        const Text('Rename'),
                      ],
                    ),
                    // Share button
                    Column(
                      children: [
                        // Icon
                        IconButton(
                            onPressed: () async {
                              // call static method to share the pdf file
                              await FileUtilities.shareFile(pdfPath);
                            },
                            icon: const Icon(Icons.share_rounded)),
                        // Label
                        const Text('Share'),
                      ],
                    ),
                    // Save Button
                    Column(
                      children: [
                        // Icon
                        IconButton(
                            onPressed: () {
                              //TODO: Implement Save pdf
                            },
                            icon: const Icon(Icons.download_rounded)),
                        // Label
                        const Text('Save'),
                      ],
                    ),
                    // Go Home button
                    Column(
                      children: [
                        // Icon
                        IconButton(
                          onPressed: () {
                            //TODO: Implement Share pdf
                          },
                          icon: const Icon(Icons.home_rounded),
                        ),
                        // Label
                        const Text('Home'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
