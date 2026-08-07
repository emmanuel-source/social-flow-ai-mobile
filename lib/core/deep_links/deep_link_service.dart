import 'dart:async';

import 'package:app_links/app_links.dart';

class DeepLinkService {
  DeepLinkService() : _appLinks = AppLinks();

  final AppLinks _appLinks;

  StreamSubscription<Uri> start(void Function(Uri uri) onLink) {
    return _appLinks.uriLinkStream.listen(
      onLink,
      onError: (_) {},
    );
  }
}
