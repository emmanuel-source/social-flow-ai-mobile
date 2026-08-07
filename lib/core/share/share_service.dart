import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<ShareResult> shareText({
    required String text,
    String? subject,
    Uri? uri,
  }) {
    return SharePlus.instance.share(
      ShareParams(text: text, subject: subject, uri: uri),
    );
  }
}
