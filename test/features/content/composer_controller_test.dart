import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  test('ajoute et retire une plateforme', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(composerControllerProvider.notifier);
    controller.togglePlatform(SocialPlatform.linkedin);
    expect(container.read(composerControllerProvider).platforms, contains(SocialPlatform.linkedin));
    controller.togglePlatform(SocialPlatform.linkedin);
    expect(container.read(composerControllerProvider).platforms, isNot(contains(SocialPlatform.linkedin)));
  });
}
