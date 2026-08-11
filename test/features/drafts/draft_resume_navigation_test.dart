import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/content/domain/entities/platform_post_variant.dart';
import 'package:socialflow_ai/features/content/domain/entities/social_post.dart';
import 'package:socialflow_ai/features/content/presentation/controllers/composer_controller.dart';
import 'package:socialflow_ai/features/content/presentation/screens/create_hub_screen.dart';
import 'package:socialflow_ai/features/drafts/domain/entities/draft.dart';
import 'package:socialflow_ai/shared/models/social_platform.dart';

void main() {
  testWidgets('the Create hub restores a selected draft into the Composer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final draft = Draft(
      id: 'resume',
      postType: PostType.video,
      sourceCaption: 'Brouillon restauré',
      mediaPaths: const ['missing-video.mp4'],
      selectedPlatforms: const {SocialPlatform.youtube},
      platformVariants: const {
        SocialPlatform.youtube: PlatformPostVariant(
          platform: SocialPlatform.youtube,
          caption: 'Version YouTube',
          sourceCaptionSnapshot: 'Brouillon restauré',
        ),
      },
      createdAt: DateTime.utc(2026, 8, 10),
      updatedAt: DateTime.utc(2026, 8, 11),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          routes: {
            AppRoutes.drafts:
                (routeContext) => Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(routeContext, draft),
                      child: const Text('Choisir le brouillon'),
                    ),
                  ),
                ),
            AppRoutes.postMedia: (_) => const _ComposerSnapshot(),
          },
          home: const CreateHubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Brouillons'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brouillons'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choisir le brouillon'));
    await tester.pumpAndSettle();

    expect(find.text('Brouillon restauré'), findsOneWidget);
    expect(find.text('video · 1 média · youtube'), findsOneWidget);
  });
}

class _ComposerSnapshot extends ConsumerWidget {
  const _ComposerSnapshot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(composerControllerProvider);
    return Scaffold(
      body: Column(
        children: [
          Text(post.caption),
          Text(
            '${post.type.name} · ${post.mediaPaths.length} média · ${post.platforms.single.name}',
          ),
        ],
      ),
    );
  }
}
