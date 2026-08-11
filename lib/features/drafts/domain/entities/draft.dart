import '../../../content/domain/entities/platform_post_variant.dart';
import '../../../content/domain/entities/social_post.dart';
import '../../../../shared/models/social_platform.dart';

class Draft {
  Draft({
    required this.id,
    required this.postType,
    required this.sourceCaption,
    required List<String> mediaPaths,
    required Set<SocialPlatform> selectedPlatforms,
    required Map<SocialPlatform, PlatformPostVariant> platformVariants,
    required this.createdAt,
    required this.updatedAt,
  }) : mediaPaths = List.unmodifiable(mediaPaths),
       selectedPlatforms = Set.unmodifiable(selectedPlatforms),
       platformVariants = Map.unmodifiable(platformVariants);

  final String id;
  final PostType postType;
  final String sourceCaption;
  final List<String> mediaPaths;
  final Set<SocialPlatform> selectedPlatforms;
  final Map<SocialPlatform, PlatformPostVariant> platformVariants;
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialPost toSocialPost() => SocialPost(
    type: postType,
    caption: sourceCaption,
    platforms: selectedPlatforms,
    mediaPaths: mediaPaths,
    platformVariants: platformVariants,
    mode: PublicationMode.draft,
  );
}
