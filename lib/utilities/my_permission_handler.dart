import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class MyPermissionHandler {
  // checks if permission is granted to camera and storage
  static Future<bool> checkPermissions() async {
    final DeviceInfoPlugin info =
        DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
    final AndroidDeviceInfo androidInfo = await info.androidInfo;

    final int androidVersion = int.parse(androidInfo.version.release);

    if (androidVersion >= 13) {
      if (await Permission.camera.isGranted &&
          await Permission.photos.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      if (await Permission.camera.isGranted &&
          await Permission.storage.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  // code borrowed from stack overflow
  // request permissions for camera and storage
  static Future<bool> requestPermission() async {
    final DeviceInfoPlugin info =
        DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
    final AndroidDeviceInfo androidInfo = await info.androidInfo;

    final int androidVersion = int.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 13) {
      final request = await [
        Permission.photos,
        Permission.camera,

        //..... as needed
      ].request(); //import 'package:permission_handler/permission_handler.dart';

      havePermission =
          request.values.every((status) => status == PermissionStatus.granted);
    } else {
      final status = await Permission.storage.request();
      final cameraStatus = await Permission.camera.request();
      havePermission = status.isGranted && cameraStatus.isGranted;
    }

    if (!havePermission) {
      // if no permission then open app-setting
      await openAppSettings();
    }

    return havePermission;
  }
}
