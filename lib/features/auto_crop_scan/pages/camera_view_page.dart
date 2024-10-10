import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_page.dart';

class CameraViewPage extends StatefulWidget {
  static navigate(context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CameraViewPage(),
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
  _CameraViewPageState createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  bool _isProcessing = false;
  List<Offset>? corners;
  GlobalKey imageWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.max)
      ..setFocusMode(FocusMode.auto);
    await _controller?.initialize();
    _controller?.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        processCameraImage(image);
      }
    });
    setState(() {});
  }

  Future<void> processCameraImage(CameraImage image) async {
    final byteData = concatenatePlanes(image.planes);
    await _sendToNative(byteData);

    _isProcessing = false;
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((Plane plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }

  Future<void> _sendToNative(Uint8List byteData) async {
    const platform = MethodChannel('com.sample.edgedetection/processor');
    var width = _controller!.value.previewSize!.width;
    var height = _controller!.value.previewSize!.height;

    try {
      String result =
          await platform.invokeMethod('processImage', <String, dynamic>{
        'byteData': byteData,
        'width': width,
        'height': height,
      });
      // [[0.0, 76.0], [639.0, 75.0], [639.0, 479.0], [0.0, 479.0]]
      if (result != "null") {
        List<dynamic> list = jsonDecode(result);
        // Assuming result is a list of offsets like [[0.0, 76.0], [639.0, 75.0], [639.0, 479.0], [0.0, 479.0]]
        setState(() {
          corners =
              list.map<Offset>((point) => Offset(point[0], point[1])).toList();
        });
      } else {
        setState(() {
          corners = null;
        });
      }
    } on PlatformException catch (e) {
      print('Failed to process image: ${e.message}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Camera preview
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(
                    _controller!,
                    key: imageWidgetKey,
                  ),
                  if (corners != null)
                    Transform.flip(
                      flipY: true,
                      child: Transform.rotate(
                        angle: pi,
                        child: EdgePainter(
                          imageWidgetKey: imageWidgetKey,
                          corners: corners,
                          controller: _controller,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // top controls bar
            Positioned(
              top: 0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Icon camera button
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, color: Colors.white)),

                      // Flash button
                      IconButton(
                        onPressed: () {
                          // Toggle flash
                          _controller!
                              .setFlashMode(
                                  _controller!.value.flashMode == FlashMode.off
                                      ? FlashMode.always
                                      : _controller!.value.flashMode ==
                                              FlashMode.auto
                                          ? FlashMode.off
                                          : FlashMode.auto)
                              .then(
                            (value) {
                              setState(() {});
                            },
                          );
                        },
                        icon: Icon(
                            _controller!.value.flashMode == FlashMode.always
                                ? Icons.flash_on_rounded
                                : _controller!.value.flashMode == FlashMode.auto
                                    ? Icons.flash_auto_rounded
                                    : Icons.flash_off_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // bottom controls bar
            Positioned(
              bottom: 5,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
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
                              // Take the picture and then go to edit page
                              _controller!.takePicture().then(
                                (value) async {
                                  await value.readAsBytes().then(
                                    (value) {
                                      EditPage.navigate(context, value);
                                    },
                                  );
                                },
                              );
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
                          final pickedFile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            Uint8List byteData = await pickedFile.readAsBytes();
                            EditPage.navigate(context, byteData);
                          }
                        },
                        icon: const Icon(Icons.photo_library_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class EdgePainter extends StatelessWidget {
  EdgePainter({
    super.key,
    required this.imageWidgetKey,
    required this.corners,
    required CameraController? controller,
  }) : _controller = controller;

  final imageWidgetKey;
  final List<Offset>? corners;
  final CameraController? _controller;

  @override
  Widget build(BuildContext context) {
    final keyContext = imageWidgetKey.currentContext!;
    final box = keyContext.findRenderObject() as RenderBox;
    return CustomPaint(
      size: Size(box.size.width, box.size.height),
      painter: CornerOverlay(corners!, _controller!.value.previewSize!),
    );
  }
}

class CornerOverlay extends CustomPainter {
  final List<Offset> corners;
  final Size previewSize;
  CornerOverlay(this.corners, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(165, 208, 208, 208)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    // this will show a rectangle around the detected object

    // Transform the corners to match the preview size
    final transformedCorners = corners.map((corner) {
      return Offset(
        (corner.dy * size.width) / previewSize.height,
        ((corner.dx * size.height) / previewSize.width),
      );
    }).toList();

    final path = Path()
      ..moveTo(transformedCorners[0].dx, transformedCorners[0].dy)
      ..lineTo(transformedCorners[1].dx, transformedCorners[1].dy)
      ..lineTo(transformedCorners[2].dx, transformedCorners[2].dy)
      ..lineTo(transformedCorners[3].dx, transformedCorners[3].dy)
      ..close();

    canvas.drawPath(path, paint);

    for (var corner in transformedCorners) {
      canvas.drawCircle(corner, 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
