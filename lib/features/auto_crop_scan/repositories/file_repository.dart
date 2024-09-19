// this class will use to save file into project directory
import 'dart:io';
import 'dart:typed_data';

class FileRepository {
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
}
