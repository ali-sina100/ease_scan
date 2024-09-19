
import 'package:ease_scan/features/auto_crop_scan/widgets/edge_detection_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:simple_edge_detection/edge_detection.dart';

// Top level function for Edge detection
Future<EdgeDetectionResult> detectEdges(String imagePath) async {
  return await EdgeDetection.detectEdges(imagePath);
}

// Top level function for cropping image
// Future<String> cropImage(String imagePath, EdgeDetectionResult edgeDetectionResult) async {

   
   

// return "re"; 
// }

class ImagePreviewPage extends StatefulWidget {
  String imagePath;

  ImagePreviewPage({super.key, required this.imagePath});

  static navigate(context, String path) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImagePreviewPage(
          imagePath: path,
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
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  bool isEdgeDetected = false;
  late Future<EdgeDetectionResult> _detectionResultFuture;

  // function to perform cropping image from choosed edges
  void _cropImage() {
    // TODO: Implement image cropping
  }

  @override
  void initState() {
    super.initState();
    _detectionResultFuture = compute(detectEdges, widget.imagePath);
  
  }




 




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // image preview and detected edges
              Center(
                  child: FutureBuilder(
                future: _detectionResultFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Stack(
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return Center(
                        child: EdgeDetectionPreview(
                            imagePath: widget.imagePath,
                            edgeDetectionResult: snapshot.requireData));
                  } else {
                    return const Center(child: Text('No data'));
                  }
                },
              )),
              //Bottom control buttons like next and retake
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    border: Border(
                      top: BorderSide(color: Colors.white30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Retake button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.camera_alt_rounded),
                          ),
                        ),
                      ),
                      // Next button
                      GestureDetector(
                        onTap: () {
                         
                        },
                        child: Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.check),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));






        
  }









  
}


