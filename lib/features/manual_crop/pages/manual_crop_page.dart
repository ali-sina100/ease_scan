import 'package:ease_scan/features/core/edge_detection_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../manual_crop.dart';

class ManualCropPage extends StatelessWidget {
  String imagePath;
  EdgeDetectionResult edgeDetectionResult;
  ManualCropPage(
      {super.key, required this.imagePath, required this.edgeDetectionResult});

  // Static function to navigate
  static navigate(
    context,
    String imagePath,
    EdgeDetectionResult edgeDetectionResult,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ManualCropPage(
          imagePath: imagePath,
          edgeDetectionResult: edgeDetectionResult,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Crop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ManualCropPreview(
          imagePath: imagePath,
          edgeDetectionResult: edgeDetectionResult,
        ),
      ),
    );
  }
}
