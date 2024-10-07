import 'package:share_plus/share_plus.dart';

class ShareUtils {
  // Function to share the app link via different platforms
  shareAppLink(String appLink) {
    Share.share(
      'Hey! Check out this awesome app: $appLink',
      subject: 'Invite to try this app',
    );
  }
}
