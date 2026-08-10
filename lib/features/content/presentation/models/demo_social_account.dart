import '../../../../shared/models/social_platform.dart';

class DemoSocialAccount {
  const DemoSocialAccount({
    required this.platform,
    required this.accountLabel,
    required this.connected,
  });

  final SocialPlatform platform;
  final String accountLabel;
  final bool connected;
}

const demoSocialAccounts = <DemoSocialAccount>[
  DemoSocialAccount(
    platform: SocialPlatform.instagram,
    accountLabel: '@socialflow',
    connected: true,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.facebook,
    accountLabel: 'Social Flow AI',
    connected: true,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.tiktok,
    accountLabel: '@socialflow',
    connected: true,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.youtube,
    accountLabel: 'Social Flow AI',
    connected: true,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.linkedin,
    accountLabel: 'Social Flow AI',
    connected: true,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.x,
    accountLabel: 'Aucun compte connecté',
    connected: false,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.threads,
    accountLabel: 'Aucun compte connecté',
    connected: false,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.pinterest,
    accountLabel: 'Aucun compte connecté',
    connected: false,
  ),
  DemoSocialAccount(
    platform: SocialPlatform.snapchat,
    accountLabel: 'Aucun compte connecté',
    connected: false,
  ),
];

DemoSocialAccount demoAccountFor(SocialPlatform platform) =>
    demoSocialAccounts.firstWhere((account) => account.platform == platform);
