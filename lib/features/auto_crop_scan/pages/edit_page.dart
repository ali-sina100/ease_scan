// ignore_for_file: public_member_api_docs, sort_constructors_first

import '../../document_enhancement/filters_page.dart';
import '../../document_exportation/pages/pdf_export_page.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_view_page.dart';

class EditPage extends StatefulWidget {
  Uint8List imageBytes;
  EditPage({
    super.key,
    required this.imageBytes,
  });

  // Static function to navigate
  static navigate(
    context,
    Uint8List imageBytes,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditPage(
          imageBytes: imageBytes,
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
  bool _isImageCropped = false;

  Future<void> _sendToNative() async {
    if (_isImageCropped) return;
    _isImageCropped = true;
    const platform = MethodChannel('com.sample.edgedetection/processor');
    final img.Image image = img.decodeImage(widget.imageBytes)!;
    int height = image.height;
    int width = image.width;

    try {
      Uint8List result = await platform.invokeMethod(
          'cropImage', <String, dynamic>{
        'byteData': widget.imageBytes,
        'height': height,
        'width': width
      });
      _image = img.decodeImage(result)!;
    } catch (e) {
      // If the function couldn't be called, display error and set the image to the original image
      _image = image;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int height = MediaQuery.of(context).size.height.toInt();

    return SafeArea(
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
                          child: Image.memory(img.encodeJpg(_image),
                              fit: BoxFit.contain),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator()),
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
                          await FiltersPage.navigate(context,
                                  Uint8List.fromList(img.encodeJpg(_image)))
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
                      onPressed: () {},
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
                        } else if (value == 'png') {
                          // Export as PNG logic
                        } else if (value == 'word') {
                          // Export as Word logic
                        } else if (value == 'pdf') {
                          // in the following line we are navigating to the PDF export page with jpg image
                          PdfExportPage.navigate(
                              context, img.encodeJpg(_image));
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
    );
  }
}
