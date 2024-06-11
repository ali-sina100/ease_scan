import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:simple_edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';

class EdgeDetectionPreview extends StatefulWidget {
  EdgeDetectionPreview(
      {required this.imagePath, required this.edgeDetectionResult});

  final String imagePath;
  final EdgeDetectionResult edgeDetectionResult;

  @override
  _EdgeDetectionPreviewState createState() => _EdgeDetectionPreviewState();
}

class _EdgeDetectionPreviewState extends State<EdgeDetectionPreview> {
  GlobalKey imageWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext mainContext) {
    return Center(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.file(File(widget.imagePath),
              fit: BoxFit.contain, key: imageWidgetKey),
          FutureBuilder<ui.Image>(
              future: loadUiImage(widget.imagePath),
              builder:
                  (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                return _getEdgePaint(snapshot, context);
              }),
        ],
      ),
    );
  }

  Widget _getEdgePaint(
      AsyncSnapshot<ui.Image> imageSnapshot, BuildContext context) {
    if (imageSnapshot.connectionState == ConnectionState.waiting)
      return Container();

    if (imageSnapshot.hasError) return Text('Error: ${imageSnapshot.error}');

    final keyContext = imageWidgetKey.currentContext;

    if (keyContext == null) {
      return Container();
    }

    final box = keyContext.findRenderObject() as RenderBox;

    Offset combinedValue = const Offset(0, 0);
    var combinedNotifier = ValueNotifier(combinedValue);

    late ValueNotifier<Offset> topLeftNotifier;
    late ValueNotifier<Offset> topRightNotifier;
    late ValueNotifier<Offset> bottomLeftNotifier;
    late ValueNotifier<Offset> bottomRightNotifier;

    topLeftNotifier = ValueNotifier(widget.edgeDetectionResult.topLeft);
    topRightNotifier = ValueNotifier(widget.edgeDetectionResult.topRight);
    bottomLeftNotifier = ValueNotifier(widget.edgeDetectionResult.bottomLeft);
    bottomRightNotifier = ValueNotifier(widget.edgeDetectionResult.bottomRight);

    double top = 0.0;
    double left = 0.0;

    double renderedImageHeight = box.size.height;
    double renderedImageWidth = box.size.width;

    double widthFactor =
        MediaQuery.of(context).size.width / imageSnapshot.data!.width;
    double heightFactor =
        MediaQuery.of(context).size.height / imageSnapshot.data!.height;
    double sizeFactor = min(widthFactor, heightFactor);

    renderedImageHeight = imageSnapshot.data!.height * sizeFactor;
    top = ((MediaQuery.of(context).size.height - renderedImageHeight) / 2);

    renderedImageWidth = imageSnapshot.data!.width * sizeFactor;
    left = ((MediaQuery.of(context).size.width - renderedImageWidth) / 2);

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // the Filled rectangle on the detected edges
        ValueListenableBuilder(
          valueListenable: combinedNotifier,
          builder: (context, value, child) {
            return CustomPaint(
              size: Size(renderedImageWidth, renderedImageHeight),
              painter: EdgePainter(
                topLeft: topLeftNotifier.value,
                topRight: topRightNotifier.value,
                bottomLeft: bottomLeftNotifier.value,
                bottomRight: bottomRightNotifier.value,
                image: imageSnapshot.data!,
                color: Colors.white,
              ),
            );
          },
        ),
        // Top Left Corner Circle
        ValueListenableBuilder(
            valueListenable: topLeftNotifier,
            builder: (BuildContext context, Offset value, Widget? child) {
              return Positioned(
                top: top + topLeftNotifier.value.dy * renderedImageHeight - 10,
                left: left + topLeftNotifier.value.dx * renderedImageWidth - 10,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    topLeftNotifier.value = Offset(
                        value.dx + details.delta.dx / box.size.width,
                        value.dy + details.delta.dy / box.size.height);

                    combinedNotifier.value = value;
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
        // Top right Corner Circle
        ValueListenableBuilder(
            valueListenable: topRightNotifier,
            builder: (BuildContext context, Offset value, Widget? child) {
              return Positioned(
                top: top + topRightNotifier.value.dy * renderedImageHeight - 10,
                left:
                    left + topRightNotifier.value.dx * renderedImageWidth - 10,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    topRightNotifier.value = Offset(
                        value.dx + details.delta.dx / box.size.width,
                        value.dy + details.delta.dy / box.size.height);
                    combinedNotifier.value = value;
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
        // Bottom right Corner Circle
        ValueListenableBuilder(
            valueListenable: bottomLeftNotifier,
            builder: (BuildContext context, Offset value, Widget? child) {
              return Positioned(
                top: top +
                    bottomLeftNotifier.value.dy * renderedImageHeight -
                    10,
                left: left +
                    bottomLeftNotifier.value.dx * renderedImageWidth -
                    10,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    bottomLeftNotifier.value = Offset(
                        value.dx + details.delta.dx / box.size.width,
                        value.dy + details.delta.dy / box.size.height);

                    combinedNotifier.value = value;
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
        // Bottom right Corner Circle
        ValueListenableBuilder(
            valueListenable: bottomRightNotifier,
            builder: (BuildContext context, Offset value, Widget? child) {
              return Positioned(
                top: top +
                    bottomRightNotifier.value.dy * renderedImageHeight -
                    10,
                left: left +
                    bottomRightNotifier.value.dx * renderedImageWidth -
                    10,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    bottomRightNotifier.value = Offset(
                        value.dx + details.delta.dx / box.size.width,
                        value.dy + details.delta.dy / box.size.height);
                    combinedNotifier.value = value;
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
      ],
    );
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final Uint8List data = await File(imageAssetPath).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image image) {
      return completer.complete(image);
    });
    return completer.future;
  }
}

class EdgePainter extends CustomPainter {
  EdgePainter(
      {required this.topLeft,
      required this.topRight,
      required this.bottomLeft,
      required this.bottomRight,
      required this.image,
      required this.color});

  Offset topLeft;
  Offset topRight;
  Offset bottomLeft;
  Offset bottomRight;

  ui.Image image;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    double top = 0.0;
    double left = 0.0;

    double renderedImageHeight = size.height;
    double renderedImageWidth = size.width;

    double widthFactor = size.width / image.width;
    double heightFactor = size.height / image.height;
    double sizeFactor = min(widthFactor, heightFactor);

    renderedImageHeight = image.height * sizeFactor;
    top = ((size.height - renderedImageHeight) / 2);

    renderedImageWidth = image.width * sizeFactor;
    left = ((size.width - renderedImageWidth) / 2);

    final path = Path()
      ..moveTo(left + topLeft.dx * renderedImageWidth,
          top + topLeft.dy * renderedImageHeight)
      ..lineTo(left + topRight.dx * renderedImageWidth,
          top + topRight.dy * renderedImageHeight)
      ..lineTo(left + bottomRight.dx * renderedImageWidth,
          top + bottomRight.dy * renderedImageHeight)
      ..lineTo(left + bottomLeft.dx * renderedImageWidth,
          top + bottomLeft.dy * renderedImageHeight)
      ..close();

    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
