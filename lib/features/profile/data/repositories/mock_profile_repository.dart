import '../../../../shared/models/social_platform.dart';
import '../../domain/entities/profile_overview.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository({
    this.delay = const Duration(milliseconds: 350),
    this.overview = demoOverview,
  });

  final Duration delay;
  final ProfileOverview overview;

  @override
  Future<ProfileOverview> fetchOverview() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return overview;
  }

  static const demoOverview = ProfileOverview(
    identity: ProfileIdentity(
      name: 'Rami',
      email: 'rami@socialflow.ai',
      planName: 'Pro',
    ),
    workspace: ProfileWorkspaceSummary(
      name: 'Social Flow AI',
      role: 'Owner',
      membersCount: 4,
    ),
    socialAccounts: [
      ProfileSocialAccount(
        platform: SocialPlatform.instagram,
        status: ProfileAccountStatus.connected,
      ),
      ProfileSocialAccount(
        platform: SocialPlatform.facebook,
        status: ProfileAccountStatus.connected,
      ),
      ProfileSocialAccount(
        platform: SocialPlatform.tiktok,
        status: ProfileAccountStatus.connected,
      ),
      ProfileSocialAccount(
        platform: SocialPlatform.youtube,
        status: ProfileAccountStatus.disconnected,
      ),
    ],
  );
}
