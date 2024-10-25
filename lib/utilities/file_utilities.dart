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

  // Function to get all generated pdf files and sort based on the date
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
          .toList()
        // sort list in descending order
        ..sort((a, b) =>
            File(b).lastModifiedSync().compareTo(File(a).lastModifiedSync()));
      return pdfFiles;
    } else {
      return [];
    }
  }

  // Function to search for a files
  static Future<List<String>> searchFiles(String query) async {
    final directory =
        Directory('/data/user/0/com.example.ease_scan/scanned_pdfs');
    if (await directory.exists()) {
      List<FileSystemEntity> fileList =
          directory.listSync(recursive: false, followLinks: false);
      List<String> pdfFiles = fileList
          .where((entity) =>
              entity is File &&
              entity.path.toLowerCase().endsWith('.pdf') &&
              entity.path.toLowerCase().contains(query.toLowerCase()))
          .map((entity) => entity.path)
          .toList();
      return pdfFiles;
    } else {
      return [];
    }
  }

  // Save file into temporary directory and when the directory is not available, create it
  // Step 1: Create a directory
  // Step 2: Save the file into the directory
  static Future<String> saveTempFile(XFile file) async {
    final directory =
        Directory('/data/user/0/com.example.ease_scan/files/temp');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    String filePath = '${directory.path}/${file.name}';
    await file.saveTo(filePath);
    return filePath;
  }

  //Delete all files in the '/data/user/0/com.example.ease_scan/files/temp' directory
  // 1:- Get the directory path
  // 2:- Check if the directory exists
  // 3:- Delete the directory

  static Future<void> deleteAllTempFiles() async {
    final directory =
        Directory('/data/user/0/com.example.ease_scan/files/temp');

    final croppedImagesDirectory =
        Directory('/data/user/0/com.example.ease_scan/files/cropped');
        // following code will delete the directory files 
        


    if (await directory.exists()) {
      directory.deleteSync(recursive: true);
    }
    if (await croppedImagesDirectory.exists()) {
      croppedImagesDirectory.deleteSync(recursive: true);
    }
  }

  // Function to rename file
  static Future<void> renameFile(String pdfPath, String newName) async {
    // Extract the directory from the original file path
    final directory = File(pdfPath).parent.path;
    // Ensure the new name includes the .pdf extension
    final newFileName = newName.endsWith('.pdf') ? newName : '$newName.pdf';
    // Construct the new file path
    String newFilePath = '$directory/$newFileName';

    // Check if the new file name already exists
    if (await File(newFilePath).exists()) {
      // Append a timestamp to the new file name to make it unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = newName.endsWith('.pdf')
          ? '${newName.replaceAll('.pdf', '')}_$timestamp.pdf'
          : '${newName}_$timestamp.pdf';
      newFilePath = '$directory/$uniqueFileName';
    }
    // Rename the file
    await File(pdfPath).rename(newFilePath);
  }

  // Function to delete a a single file
  static Future<void> deleteFile(String filePath) async {
    await File(filePath).delete();
  }
}
