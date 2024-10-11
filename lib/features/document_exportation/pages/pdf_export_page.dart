import 'dart:typed_data';
import 'package:ease_scan/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../utilities/file_utilities.dart';

class PdfExportPage extends StatefulWidget {
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

  @override
  State<PdfExportPage> createState() => _PdfExportPageState();
}

class _PdfExportPageState extends State<PdfExportPage> {
  final pdfDoc = pw.Document();
  // Overly entry to show overlay for renaming the file
  OverlayEntry? overlayEntry;
  // path to saved Pdf file
  String pdfPath = '';

  // Function to create the pdf file
  Future<void> _createPdf() async {
    pdfDoc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(widget.image_file)),
          );
        },
      ),
    );
    // put the saved pdf file path into the pdfPath variable
    await savePDF().then(
      (value) {
        // Show toast message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('PDF file saved successfully'),
          ),
        );
      },
    );
  }

  // function to save the pdf file
  Future<void> savePDF() async {
    var savedFile = await pdfDoc.save();
    List<int> fileInts = List.from(savedFile);
    pdfPath = await FileUtilities.savePDF(Uint8List.fromList(fileInts));
  }

  // show overlay
  void _showOverlay() {
    overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(overlayEntry!);
  }

  // Remvoe overlay
  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // create ovelay entry
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Material(
            color: Colors.grey.withOpacity(0.5),
            child: Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    width: 300,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 29, 29, 29),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text field for renaming the file
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Enter new name',
                            ),
                            onSubmitted: (value) {
                              // rename the file
                              FileUtilities.renameFile(pdfPath, value);
                              _removeOverlay();
                            },
                          ),
                        ),

                        // Button to cancel the renaming
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Cancel button
                            ElevatedButton(
                              onPressed: () {
                                _removeOverlay();
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _removeOverlay();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Exit'),
                  content: const Text('Discard the current document?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        HomeScreen.navigate(context);
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          // show name of the document in the app bar
          title: Text(
            pdfPath.split('/').last,
            style: const TextStyle(fontSize: 14),
          ),
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
                      child: Image.memory(widget.image_file),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
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
                      bottomBarButton(() {
                        _showOverlay();
                      }, Icons.edit_rounded, 'Rename'),

                      // Share button
                      bottomBarButton(() {
                        FileUtilities.shareFile(pdfPath);
                      }, Icons.share_rounded, 'Share'),

                      // Go Home button
                      bottomBarButton(() {
                        HomeScreen.navigate(context);
                      }, Icons.home_rounded, 'Home'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column bottomBarButton(Function f, IconData icon, String label) {
    return Column(
      children: [
        // Icon
        IconButton(
          onPressed: () {
            f();
          },
          icon: Icon(
            icon,
            size: 22,
          ),
        ),
        // Label
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
