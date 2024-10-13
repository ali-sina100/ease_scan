import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class FiltersPage extends StatefulWidget {
  final img.Image originalImage;
  FiltersPage({super.key, required this.originalImage});

  // static method for navigation
  static navigate(context, imagePath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FiltersPage(originalImage: imagePath),
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
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  late img.Image editedImage;
  late img.Image originalImage;
  late Map<String, img.Image> filterThumbnails;

  @override
  void initState() {
    super.initState();
    originalImage = widget.originalImage;
    editedImage = img.copyResize(widget.originalImage,
        width: widget.originalImage.width, height: widget.originalImage.height);
    filterThumbnails = _generateFilterThumbnails();
  }

  Map<String, img.Image> _generateFilterThumbnails() {
    // a very small thumnail version of original image
    img.Image thumbnail = img.copyResize(widget.originalImage, width: 10);

    return {
      'No Filter': img.copyResize(thumbnail, width: 100),
      'Grayscale': img.copyResize(img.grayscale(thumbnail), width: 100),
      'Sepia': img.copyResize(img.sepia(thumbnail), width: 100),
      'Invert': img.copyResize(img.invert(thumbnail), width: 100),
      'Brightness': img.copyResize(img.adjustColor(thumbnail, brightness: 1.5),
          width: 100),
      'Contrast':
          img.copyResize(img.contrast(thumbnail, contrast: 150), width: 100),
    };
  }

  void applyFilter(img.Image Function(img.Image) filter) {
    setState(() {
      editedImage = img.copyResize(filter(widget.originalImage),
          width: widget.originalImage.width,
          height: widget.originalImage.height);
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

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
              child: Image.memory(img.encodeJpg(editedImage)),
            ),
          ),
          // bottom bar filter list
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.14,
              color: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }
}
