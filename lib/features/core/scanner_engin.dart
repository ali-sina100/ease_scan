// Summary: ScannerEngin class
import 'package:flutter/services.dart';

class ScannerEngin {
  static const platform = MethodChannel('com.sample.edgedetection/processor');
  static final ScannerEngin _instance = ScannerEngin();
  String detectCornersMethodName = 'processImage';
  String cropImageMethodName = 'cropImage';

  // Instance Creator
  static get instance {
    return _instance;
  }

  // Summary: this function take a byteData,width, and height of an image and return a list of corners
  Future<List<Offset>> detectCorners(
    Uint8List byteData,
    double width,
    double height,
  ) async {
    // Summary: this function take a byteData of an image and return a list of corners
    try {
      final List<dynamic> result = await platform.invokeMethod(
        detectCornersMethodName,
        <String, dynamic>{
          'byteData': byteData,
          'width': width,
          'height': height,
        },
      );

      if (result.isEmpty) {
        return [];
      }

      // Summary: this function take a byteData of an image and return a list of corners
      return result.map((e) {
        return Offset(e['x'], e['y']);
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Summary: this function detect corners of and image and crop the image based on the corners and return the path of the cropped image
  // Step 1: send request to native code to crop the image, that have saved in the path "files/temp/temp.jpg"
  // Step 2: return the path of the cropped image
  Future<String> processCroppingImage(String imagePath) async {
    try {
      final String result = await platform.invokeMethod(cropImageMethodName, {
        'image_path': imagePath,
      });
      return result;
    } catch (e) {
      print(e);
      return imagePath;
    }
  }

  // Summary : this function take a file path and then apply filter on that image and return the path of the image
  // Step 1: send request to native code to apply greyscale filter on the image, that have saved in the path "files/temp/temp.jpg"
  // Step 2: return the path of the image
  // Step 3: if any error occurs then return the original image path

  Future<String> applyFilter(String imagePath, String filterName) async {
    try {
      final String result = await platform.invokeMethod('applyFilter', {
        'image_path': imagePath,
        'filter_name': filterName,
      });
      return result;
    } catch (e) {
      return imagePath;
    }
  }
}
