import 'dart:io';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

class FileUtilities {
  // save a file into /data/user/0/com.example.ease_scan/scanned_images
  Future<String> saveJPGFile(File file) async {
    final directory =
        Directory('/data/user/0/com.example.ease_scan/scanned_images');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    String filePath = '${directory.path}/${file.path.split('/').last}';
    await file.copy(filePath);
    return filePath;
  }

  // get all jpg files into required directory
  Future<List<String>> getAllJPGFiles() async {
    final directory =
        Directory('/data/user/0/com.example.ease_scan/scanned_images');
    if (await directory.exists()) {
      List<FileSystemEntity> fileList =
          directory.listSync(recursive: false, followLinks: false);
      List<String> jpgFiles = fileList
          .where((entity) =>
              entity is File && entity.path.toLowerCase().endsWith('.jpg'))
          .map((entity) => entity.path)
          .toList();
      return jpgFiles;
    } else {
      return [];
    }
  }

  // Share the pdf file
  static Future<void> shareFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  // Save a single file to the device
  static Future<String> savePDF(Uint8List pdfBytes) async {
    final directory =
        Directory('/data/user/0/com.example.ease_scan/scanned_pdfs');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final file = File(
        '${directory.path}/EaseScan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(pdfBytes);
    // Return the path of the saved file
    return file.path;
  }
  // Function to get all generated pdf files
  static Future<List<String>> getAllPDFFiles() async {
    final directory =
        Directory('/data/user/0/com.example.ease_scan/scanned_pdfs');
    if (await directory.exists()) {
      List<FileSystemEntity> fileList =
          directory.listSync(recursive: false, followLinks: false);
      List<String> pdfFiles = fileList
          .where((entity) =>
              entity is File && entity.path.toLowerCase().endsWith('.pdf'))
          .map((entity) => entity.path)
          .toList();
      return pdfFiles;
    } else {
      return [];
    }
  }
  // Function to raname file
  static void renameFile(String pdfPath, String value) {
    File file = File(pdfPath);
    file.renameSync(pdfPath.replaceAll(RegExp(r'\d+'), value));
  }
}
