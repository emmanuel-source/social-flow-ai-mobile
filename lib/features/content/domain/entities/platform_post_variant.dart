import '../../../../shared/models/social_platform.dart';

/// An immutable caption variant for one target platform.
///
/// Media remain owned by [SocialPost] and are intentionally not duplicated per
/// platform. [sourceCaptionSnapshot] records the source used when the variant
/// was created or last reset, so presentation can signal a later source change.
class PlatformPostVariant {
  const PlatformPostVariant({
    required this.platform,
    required this.caption,
    required this.sourceCaptionSnapshot,
  });

  factory PlatformPostVariant.fromSource({
    required SocialPlatform platform,
    required String sourceCaption,
  }) => PlatformPostVariant(
    platform: platform,
    caption: sourceCaption,
    sourceCaptionSnapshot: sourceCaption,
  );

  final SocialPlatform platform;
  final String caption;
  final String sourceCaptionSnapshot;

  bool matchesSource(String sourceCaption) => caption == sourceCaption;

  bool sourceChangedSinceLastSync(String sourceCaption) =>
      sourceCaptionSnapshot != sourceCaption;

  PlatformPostVariant copyWith({
    String? caption,
    String? sourceCaptionSnapshot,
  }) => PlatformPostVariant(
    platform: platform,
    caption: caption ?? this.caption,
    sourceCaptionSnapshot: sourceCaptionSnapshot ?? this.sourceCaptionSnapshot,
  );
}
