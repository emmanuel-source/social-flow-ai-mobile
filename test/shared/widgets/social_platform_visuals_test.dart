import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';
import 'package:socialflow_ai/shared/widgets/social_platform_visuals.dart';

void main() {
  test('defines a complete visual identity for all nine platforms', () {
    expect(SocialPlatform.values, hasLength(9));

    for (final platform in SocialPlatform.values) {
      final visuals = SocialPlatformVisuals.of(platform);
      expect(visuals.label, platform.label);
      expect(visuals.icon.codePoint, isNonZero);
      expect(visuals.brandColor, isNot(Colors.transparent));
      expect(visuals.subtleBackground.a, greaterThan(0));
    }
  });

  testWidgets('renders all platforms with accessible brand semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Wrap(
          children: [
            for (final platform in SocialPlatform.values)
              SocialPlatformIcon(platform: platform),
          ],
        ),
      ),
    );

    for (final platform in SocialPlatform.values) {
      expect(find.bySemanticsLabel(platform.label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact chips remain readable in light and dark themes', (
    tester,
  ) async {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Material(
            child: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final platform in SocialPlatform.values)
                      SocialPlatformChip(
                        platform: platform,
                        selected: platform == SocialPlatform.instagram,
                        onSelected: (_) {},
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Instagram, sélectionné'), findsOneWidget);
    }
  });
}
