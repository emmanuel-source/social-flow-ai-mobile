import '../../../../shared/models/social_platform.dart';

class PublicationTarget {
  const PublicationTarget({required this.platform, required this.accountId, this.enabled = true});

  final SocialPlatform platform;
  final String accountId;
  final bool enabled;
}
