import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/bootstrap.dart';

void main() {
  test('initializes storage before completing bootstrap', () async {
    var storageInitialized = false;

    await AppBootstrap.initialize(
      initializeStorage: () async {
        storageInitialized = true;
      },
    );

    expect(storageInitialized, isTrue);
  });
}
