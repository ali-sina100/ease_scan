import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class FiltersPage extends StatefulWidget {
  final Uint8List originalImageData;
  const FiltersPage({super.key, required this.originalImageData});

  // static method for navigation
  static Future<Uint8List> navigate(context, imagePath) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FiltersPage(originalImageData: imagePath),
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
    return result;
  }

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  late img.Image editedImage;
  late img.Image originalImage;
  late Uint8List originalImageData;
  late Map<String, img.Image> filterThumbnails;

  @override
  void initState() {
    super.initState();
    originalImage = img.decodeImage(widget.originalImageData)!;
    editedImage = img.decodeImage(widget.originalImageData)!;
    originalImageData = widget.originalImageData;

    filterThumbnails = _generateFilterThumbnails();
  }

  Map<String, img.Image> _generateFilterThumbnails() {
    // a very small thumnail version of original image
    img.Image thumbnail =
        img.copyResize(originalImage, width: originalImage.width ~/ 10);
    Uint8List thumbnailData = img.encodeJpg(thumbnail);
    return {
      'No Filter': img.decodeImage(thumbnailData)!,
      'AutoEnhance': img.decodeImage(thumbnailData)!,
      'Grayscale': img.grayscale(img.decodeImage(thumbnailData)!),
      'Sepia': img.sepia(img.decodeImage(thumbnailData)!),
      'Invert': img.invert(img.decodeImage(thumbnailData)!),
      'Brightness':
          img.adjustColor(img.decodeImage(thumbnailData)!, brightness: 1.5),
      'Contrast': img.contrast(img.decodeImage(thumbnailData)!, contrast: 150),
    };
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
      ),
      body: Stack(
        children: [
          // Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 0,
            child: Padding(
                padding: const EdgeInsets.all(14.0),
                // show edidted image
                child: Image.memory(
                    Uint8List.fromList(img.encodeJpg(editedImage)))),
          ),
          // bottom bar filter list
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.14,
              color: Colors.white10,
              width: width,
              child: Row(
                children: [
                  // Filters list
                  Expanded(
                    flex: 5,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: filterThumbnails.keys
                          .map((filterName) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    switch (filterName) {
                                      case 'No Filter':
                                        editedImage =
                                            img.decodeImage(originalImageData)!;
                                        break;
                                      case 'AutoEnhance':
                                        editedImage =
                                            img.decodeImage(originalImageData)!;
                                        // Adjust brightness
                                        editedImage = img.adjustColor(
                                            editedImage,
                                            brightness: 1.2);
                                        // Adjust contrast
                                        editedImage = img.contrast(editedImage,
                                            contrast: 150);
                                        // Adjust gamma (color balance)
                                        editedImage = img.adjustColor(
                                            editedImage,
                                            gamma: 1.1);
                                        break;
                                      case 'Grayscale':
                                        editedImage = img.grayscale(img
                                            .decodeImage(originalImageData)!);
                                        break;
                                      case 'Sepia':
                                        editedImage = img.sepia(img
                                            .decodeImage(originalImageData)!);
                                        break;
                                      case 'Invert':
                                        editedImage = img.invert(img
                                            .decodeImage(originalImageData)!);
                                        break;
                                      case 'Brightness':
                                        editedImage = img.adjustColor(
                                            img.decodeImage(originalImageData)!,
                                            brightness: 1.5);
                                        break;
                                      case 'Contrast':
                                        editedImage = img.contrast(
                                            img.decodeImage(originalImageData)!,
                                            contrast: 150);
                                        break;
                                    }
                                    setState(() {});
                                  },
                                  child: Column(
                                    children: [
                                      Image.memory(
                                        img.encodeJpg(
                                            filterThumbnails[filterName]!),
                                        width: 65,
                                        height: 65,
                                      ),
                                      Text(
                                        filterName,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  // Save button
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 0.2)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              // Save the edited image
                              Navigator.pop(
                                  context, img.encodeJpg(editedImage));
                            },
                            icon: const Icon(
                              Icons.save,
                              color: Colors.blue,
                            ),
                          ),
                          const Text(
                            'Save',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
