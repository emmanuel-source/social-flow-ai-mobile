import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:socialflow_ai/core/storage/local_storage.dart';

void main() {
  late Directory storageDirectory;

  setUp(() async {
    storageDirectory = await Directory.systemTemp.createTemp(
      'socialflow_local_storage_test_',
    );
    await LocalStorage.initialize(path: storageDirectory.path);
  });

  tearDown(() async {
    await Hive.close();
    if (await storageDirectory.exists()) {
      await storageDirectory.delete(recursive: true);
    }
  });

  test('persists foundation settings and session values', () async {
    expect(LocalStorage.authToken, isNull);
    expect(LocalStorage.darkMode, isFalse);
    expect(LocalStorage.onboardingCompleted, isFalse);
    expect(LocalStorage.selectedWorkspaceId, isNull);

    await LocalStorage.setAuthToken('test-token');
    await LocalStorage.setDarkMode(true);
    await LocalStorage.setOnboardingCompleted(true);
    await LocalStorage.setSelectedWorkspaceId('workspace-test');

    expect(LocalStorage.authToken, 'test-token');
    expect(LocalStorage.darkMode, isTrue);
    expect(LocalStorage.onboardingCompleted, isTrue);
    expect(LocalStorage.selectedWorkspaceId, 'workspace-test');

    await LocalStorage.setAuthToken(null);
    expect(LocalStorage.authToken, isNull);
  });
}
