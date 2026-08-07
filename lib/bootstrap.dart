import 'core/storage/local_storage.dart';

abstract final class AppBootstrap {
  static Future<void> initialize() async {
    await LocalStorage.initialize();
  }
}
