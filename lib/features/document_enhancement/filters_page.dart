import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../core/scanner_engin.dart';

class FiltersPage extends StatefulWidget {
  final String image_path;
  final Function callback;
  FiltersPage({super.key, required this.image_path, required this.callback});

  // static method for navigation
  static Future<String> navigate(
      context, String imagePath, Function callback) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FiltersPage(
          image_path: imagePath,
          callback: callback,
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
    return ''; // Add a return statement to ensure a String is always returned
  }

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  late String path;
  // Replace the widget.image_path with path
  Future<void> saveFilteredImage() async {
    widget.callback(path);
    Navigator.pop(context);
  }

  @override
  void initState() {
    path = widget.image_path;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Filters'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          Image.file(File(path)),
          // Filter and ok button
          Positioned(
            bottom: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // Filter and ok button
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        //Original
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              path = widget.image_path;
                            });
                          },
                          child: SizedBox(
                            height: 100,
                            width: 50,
                            child: Column(
                              children: [
                                // Thumbnail
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 70, 129, 237),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                ),
                                const Text(
                                  "Original",
                                  style: TextStyle(fontSize: 13),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        //Auto Enhance
                        GestureDetector(
                          onTap: () async {
                            path = await ScannerEngin.instance
                                .applyFilter(
                                    imagePath: widget.image_path,
                                    filterName: "ENHANCE")
                                .then((value) {
                              setState(() {
                                path = value;
                              });
                            });
                          },
                          child: Column(
                            children: [
                              // Thumbnail
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                              ),
                              const Text(
                                "Auto Enhance",
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        //Greyscale Filter
                        GestureDetector(
                          onTap: () async {
                            await ScannerEngin.instance
                                .applyFilter(
                                    imagePath: widget.image_path,
                                    filterName: "GREYSCALE")
                                .then((value) {
                              setState(() {
                                path = value;
                              });
                            });
                          },
                          child: Column(
                            children: [
                              // Thumbnail
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                              ),
                              const Text(
                                "Greyscale",
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),
                        // No Shadow
                        GestureDetector(
                          onTap: () async {
                            path = await ScannerEngin.instance
                                .applyFilter(
                                    imagePath: widget.image_path,
                                    filterName: "NO_SHADOW")
                                .then((value) {
                              setState(() {
                                path = value;
                              });
                            });
                          },
                          child: Column(
                            children: [
                              // Thumbnail
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                              ),
                              const Text(
                                "No Shadow",
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        // Black and White
                        GestureDetector(
                          onTap: () async {
                            path = await ScannerEngin.instance
                                .applyFilter(
                                    imagePath: widget.image_path,
                                    filterName: "BLACK_WHITE")
                                .then((value) {
                              setState(() {
                                path = value;
                              });
                            });
                          },
                          child: Column(
                            children: [
                              // Thumbnail
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 33, 33, 33),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                              ),
                              const Text(
                                "B&W",
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        // Lighten
                        GestureDetector(
                          onTap: () async {
                            path = await ScannerEngin.instance
                                .applyFilter(
                                    imagePath: widget.image_path,
                                    filterName: "LIGHTEN")
                                .then((value) {
                              setState(() {
                                path = value;
                              });
                            });
                          },
                          child: Column(
                            children: [
                              // Thumbnail
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12))),
                              ),
                              const Text(
                                "Lighten",
                                style: TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Button
                  GestureDetector(
                    onTap: () async {
                      await saveFilteredImage();
                    },
                    child: Center(
                      child: Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width * 0.20,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(
                          Icons.check,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
