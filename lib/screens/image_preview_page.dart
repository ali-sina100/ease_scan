// This page used to show an image after receiving its path from the previous page
//

import 'dart:io';

import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  String path; // Path of the image to be displayed
   MyWidget({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Preview"),
      ),
      body: Center(
        child: Image.file(File(path)),
      ),
    );
  }
}

