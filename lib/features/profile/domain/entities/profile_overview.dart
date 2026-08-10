import '../../../../shared/models/social_platform.dart';

enum ProfileAccountStatus { connected, disconnected }

class ProfileIdentity {
  const ProfileIdentity({
    required this.name,
    required this.email,
    required this.planName,
  });

  final String name;
  final String email;
  final String planName;
}

class ProfileWorkspaceSummary {
  const ProfileWorkspaceSummary({
    required this.name,
    required this.role,
    required this.membersCount,
  });

  final String name;
  final String role;
  final int membersCount;
}

class ProfileSocialAccount {
  const ProfileSocialAccount({required this.platform, required this.status});

  final SocialPlatform platform;
  final ProfileAccountStatus status;

  bool get isConnected => status == ProfileAccountStatus.connected;
}

class ProfileOverview {
  const ProfileOverview({
    required this.identity,
    required this.workspace,
    required this.socialAccounts,
    this.isDemo = true,
  });

  final ProfileIdentity identity;
  final ProfileWorkspaceSummary workspace;
  final List<ProfileSocialAccount> socialAccounts;
  final bool isDemo;

  int get connectedAccountsCount =>
      socialAccounts.where((account) => account.isConnected).length;
}
