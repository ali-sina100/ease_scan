// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditPage extends StatefulWidget {
  Uint8List imageBytes;
  EditPage({
    Key? key,
    required this.imageBytes,
  }) : super(key: key);

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
          var begin = const Offset(-1.0, 0.0);
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
  late Uint8List result = Uint8List(0);

  Future<void> _sendToNative() async {
    const platform = MethodChannel('com.sample.edgedetection/processor');
    final ui.Image image = await decodeImageFromList(widget.imageBytes);
    int height = image.height;
    int width = image.width;

    try {
      result = await platform.invokeMethod('cropImage', <String, dynamic>{
        'byteData': widget.imageBytes,
        'height': height,
        'width': width
      });
      if (result != "null") {
        print("Successfully cropped");
      } else {
        print("Failed");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // using future builder to call the native code
      body: FutureBuilder(
        future: _sendToNative(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.memory(
                  fit: BoxFit.scaleDown,
                  Uint8List.fromList(
                      result.lengthInBytes == 0 ? widget.imageBytes : result),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
