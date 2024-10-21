// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:ease_scan/features/core/edge_detection_result.dart';
import 'package:ease_scan/features/core/scanner_engin.dart';
import 'package:ease_scan/utilities/file_utilities.dart';

import '../../document_enhancement/filters_page.dart';
import '../../document_exportation/pages/pdf_export_page.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../manual_crop/manual_crop.dart';
import '../../manual_crop/pages/manual_crop_page.dart';
import 'camera_view_page.dart';

class EditPage extends StatefulWidget {
  String filePath;
  EditPage({
    required this.filePath,
    super.key,
  });

  // Static function to navigate
  static navigate(
    context,
    String filePath,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditPage(
          filePath: filePath,
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
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  //original image
  late img.Image _image;
  late String cropedImagePath;
  bool _isImageCropped = false;

  Future<void> _sendToNative() async {
    if (_isImageCropped) return;
    _isImageCropped = true;

    try {
      final result =
          await ScannerEngin.instance.processCroppingImage(widget.filePath);
      cropedImagePath = result.toString();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    cropedImagePath = widget.filePath;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int height = MediaQuery.of(context).size.height.toInt();

    return WillPopScope(
      onWillPop: () async {
        FileUtilities.deleteAllTempFiles();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: const Text('Edit Image and Export'),
          ),
          // using future builder to call the native code
          body: Stack(
            children: [
              // Image
              Positioned(
                child: FutureBuilder(
                  future: _sendToNative(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Center(
                        child: SizedBox(
                          height: height * 0.75,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.file(
                              File(cropedImagePath),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              height: height * 0.75,
                              child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Image.file(
                                    File(widget.filePath),
                                  )),
                            ),
                          ),
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              // Bottom Button bar
              Positioned(
                bottom: 5,
                left: 10,
                right: 10,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 0.2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Go back to camera button
                      IconButton(
                          onPressed: () {
                            CameraViewPage.navigate(context);
                          },
                          icon: const Icon(
                            Icons.replay,
                            color: Colors.white,
                          )),
                      // Fitlers
                      IconButton(
                          onPressed: () async {
                            // Navigate to the filters page, create a path of _image and send it to FiltersPagec
                            await FiltersPage.navigate(context, cropedImagePath)
                                .then(
                              (value) {
                                setState(() {
                                  _image = img.decodeImage(value)!;
                                });
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.filter,
                            color: Colors.white,
                          )),
                      // Crop
                      IconButton(
                        onPressed: () {
                          final topLeft = Offset(0.0, 0.0);
                          final topRight = Offset(1.0, 0.0);
                          final bottomLeft = Offset(0.0, 1.0);
                          final bottomRight = Offset(1.0, 1.0);
                          ManualCropPage.navigate(
                              context,
                              cropedImagePath,
                              EdgeDetectionResult(
                                  topLeft: topLeft,
                                  topRight: topRight,
                                  bottomLeft: bottomLeft,
                                  bottomRight: bottomRight));
                        },
                        icon: const Icon(
                          Icons.crop,
                          color: Colors.white,
                        ),
                      ),
                      // Export button
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          // Handle the selected export option here
                          if (value == 'jpg') {
                            // Export as JPG logic
                            PdfExportPage.navigate(context, cropedImagePath);
                          } else if (value == 'png') {
                            // Export as PNG logic
                            PdfExportPage.navigate(context, cropedImagePath);
                          } else if (value == 'word') {
                            // Export as Word logic
                            PdfExportPage.navigate(context, cropedImagePath);
                          } else if (value == 'pdf') {
                            // in the following line we are navigating to the PDF export page with jpg image
                            PdfExportPage.navigate(context, cropedImagePath);
                          }
                        },
                        icon: const Icon(Icons.upload_rounded,
                            color: Colors.white), // Icon for the export button
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem(
                              value: 'jpg',
                              child: Text('Export as JPG'),
                            ),
                            const PopupMenuItem(
                              value: 'png',
                              child: Text('Export as PNG'),
                            ),
                            const PopupMenuItem(
                              value: 'word',
                              child: Text('Export as Word'),
                            ),
                            const PopupMenuItem(
                              value: 'pdf',
                              child: Text('Export as PDF'),
                            ),
                          ];
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
