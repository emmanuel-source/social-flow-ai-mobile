import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/media/media_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/public_http_client.dart';
import '../../core/share/share_service.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());
final publicHttpClientProvider = Provider<PublicHttpClient>((ref) {
  final client = PublicHttpClient();
  ref.onDispose(client.close);
  return client;
});
final mediaServiceProvider = Provider<MediaService>((ref) => MediaService());
final shareServiceProvider = Provider<ShareService>((ref) => ShareService());
