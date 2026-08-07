enum SubscriptionTier { free, creator, pro, agency }

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.tier,
    required this.maxSocialAccounts,
    required this.monthlyPublications,
    required this.aiCredits,
  });

  final SubscriptionTier tier;
  final int maxSocialAccounts;
  final int monthlyPublications;
  final int aiCredits;
}
