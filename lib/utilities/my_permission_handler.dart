import 'package:permission_handler/permission_handler.dart';

class MyPermissionHandler {
  // checks if permission is granted to camera and storage
  static Future<bool> checkPermissions() async {
    if (await Permission.camera.isGranted &&
        await Permission.photos.isGranted) {
      print("permission: ");
      print(await Permission.camera.isGranted);
      print(await Permission.photos.isGranted);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    if (await Permission.camera.request().isGranted &&
        await Permission.photos.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
