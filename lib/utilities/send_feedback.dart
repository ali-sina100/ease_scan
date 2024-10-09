import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';

dynamic sendfeedback() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String androidVersion = androidInfo.version.release;
    String model = androidInfo.model;
    String subject = "Feedback on ScanEase App";
    String body =
        "Android Version: $androidVersion\n model:$model\n\n write your feedback here...";

    Uri email = Uri(
        scheme: 'mailto',
        path: 'gentlehub00@gmail.com',
        query:
            "subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}");
    await launchUrl(email);
  } catch (e) {
    print('error in send feedback $e');
  }
}
