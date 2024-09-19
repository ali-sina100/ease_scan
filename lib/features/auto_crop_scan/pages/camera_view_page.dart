// This page contains code to handle capturing image from camera and also import it from gallery

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/file_repository.dart';
import 'image_preview_page.dart';

class CameraViewPage extends StatefulWidget {
  const CameraViewPage({super.key});

  // static method for navigation
  static navigate(context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CameraViewPage(),
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
  State<CameraViewPage> createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {

  CameraController? controller = null;
  late List<CameraDescription> cameras;
  bool cameraInitialized = false;
  @override

  void initState() {
    checkForCameras().then((value) {
      _initializeController();
    });
    super.initState();
  }

  // Check for available cameras
  Future<void> checkForCameras() async {
    cameras = await availableCameras();
  }

  // Intialize the camera controller
  _initializeController() {
    controller = CameraController(cameras[0], ResolutionPreset.max)
      ..setFocusMode(FocusMode.auto);
    controller!.initialize().then((_) {

      if (!mounted) {
        return;
      }

    setState(() {

      cameraInitialized = true;
      
    }
    
        );
    });
  }

  // go to ImagePreviewPage
  goToImagePreviewPage(String path) async {
    // this code will save the file into project directory/scanned_images
    final file = File(path);
    String newPath = await FileRepository().saveJPGFile(file);

    ImagePreviewPage.navigate(context, newPath);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: cameraInitialized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // top controls bar
                    Padding(
                      
                      padding: const EdgeInsets.all(15),
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          // Close Icon camera button
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon:
                                  const Icon(Icons.close, color: Colors.white)),

                          // Flash button
                          IconButton(
                            onPressed: () {
                              // Toggle flash
                              controller!.setFlashMode(
                                  controller!.value.flashMode == FlashMode.off
                                      ? FlashMode.torch
                                      : FlashMode.off);
                            },

                            icon: const Icon(Icons.flash_on_rounded,
                                color: Colors.white),
                          ),

                        ],

                      ),

                    ),

                    // Camera preview
                    CameraPreview(controller!),
                     // bottom controls bar

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // empty sized box to align the buttons
                          const SizedBox(
                            width: 40,
                          ),
                          // Capture Button

                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final path = await controller!.takePicture();
                                  goToImagePreviewPage(path.path);
                                },
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 181, 181, 181),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Gallery button
                          IconButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                goToImagePreviewPage(pickedFile.path);
                              }
                            },
                            icon: const Icon(Icons.photo_library_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
            )
    );
  }
}
