import 'core/storage/local_storage.dart';

abstract final class AppBootstrap {
  static Future<void> initialize({
    Future<void> Function()? initializeStorage,
  }) async {
    await (initializeStorage ?? LocalStorage.initialize)();
  }
}
