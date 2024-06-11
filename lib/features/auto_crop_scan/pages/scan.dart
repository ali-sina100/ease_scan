import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_edge_detection/edge_detection.dart';

import '../widgets/camera_view.dart';
import '../widgets/edge_detection_preview.dart';
import '../utils/edge_detector.dart';

class Scan extends StatefulWidget {
  //static method for navigation
  static navigate(context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Scan(),
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
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  late CameraController controller;
  late List<CameraDescription> cameras;
  late String? imagePath = null;
  late EdgeDetectionResult? edgeDetectionResult = null;

  @override
  void initState() {
    super.initState();
    checkForCameras().then((value) {
      _initializeController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          _getMainWidget(),
          _getBottomBar(),
        ],
      ),
      bottomNavigationBar: imagePath != null
          ? const BottomAppBar(
              height: 60, color: Color.fromARGB(255, 20, 20, 20))
          : null,
    );
  }

  Widget _getMainWidget() {
    if (imagePath == null && edgeDetectionResult == null) {
      return CameraView(controller: controller);
    }

    return EdgeDetectionPreview(
      imagePath: imagePath!,
      edgeDetectionResult: edgeDetectionResult!,
    );
  }

  Future<void> checkForCameras() async {
    cameras = await availableCameras();
  }

  void _initializeController() {
    if (cameras.isEmpty) {
      return;
    }

    controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
      enableAudio: false,
    )
      ..setFocusMode(FocusMode.auto)
      ..lockCaptureOrientation(DeviceOrientation.portraitUp);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future _detectEdges(String filePath) async {
    if (!mounted || filePath == null) {
      return;
    }

    setState(() {
      imagePath = filePath;
    });

    EdgeDetectionResult result = await EdgeDetector().detectEdges(filePath);

    setState(() {
      edgeDetectionResult = result;
    });
  }

  void onTakePictureButtonPressed() async {
    String filePath =
        await controller.takePicture().then((value) => value.path);
    await _detectEdges(filePath);
  }

  void _onGalleryButtonPressed() async {
    final picker = ImagePicker();
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    final filePath = pickedFile!.path;

    _detectEdges(filePath);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _getButtonRow() {
    if (imagePath != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          foregroundColor: Colors.white,
          child: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              edgeDetectionResult = null;
              imagePath = null;
            });
          },
        ),
      );
    }

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Take picture button
      Container(
        height: 70,
        width: 70,
        
      ),
      const SizedBox(width: 16),
      FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.image),
        onPressed: _onGalleryButtonPressed,
      ),
    ]);
  }

  Padding _getBottomBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _getButtonRow(),
      ),
    );
  }
}
