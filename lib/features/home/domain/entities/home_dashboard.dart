import '../../../../shared/models/social_platform.dart';

enum HomeMetricType { views, engagement, followers, publications }

enum HomePublicationStatus { scheduled, review, published, draft }

class HomeWorkspaceSummary {
  const HomeWorkspaceSummary({required this.id, required this.name});

  final String id;
  final String name;
}

class HomeNetworkSummary {
  const HomeNetworkSummary({required this.platform, required this.connected});

  final SocialPlatform platform;
  final bool connected;
}

class HomeMetric {
  const HomeMetric({
    required this.type,
    required this.label,
    required this.value,
    required this.trend,
  });

  final HomeMetricType type;
  final String label;
  final String value;
  final String trend;
}

class HomeScheduledPost {
  const HomeScheduledPost({
    required this.id,
    required this.title,
    required this.platform,
    required this.scheduleLabel,
    required this.contentType,
    required this.status,
  });

  final String id;
  final String title;
  final SocialPlatform platform;
  final String scheduleLabel;
  final String contentType;
  final HomePublicationStatus status;
}

class HomeRecentPost {
  const HomeRecentPost({
    required this.id,
    required this.title,
    required this.platform,
    required this.preview,
    required this.status,
    required this.primaryMetric,
  });

  final String id;
  final String title;
  final SocialPlatform platform;
  final String preview;
  final HomePublicationStatus status;
  final String primaryMetric;
}

class HomePerformanceTrend {
  const HomePerformanceTrend({
    required this.label,
    required this.change,
    required this.points,
  });

  final String label;
  final String change;
  final List<double> points;
}

class HomeAiSuggestion {
  const HomeAiSuggestion({
    required this.title,
    required this.message,
    required this.actionLabel,
  });

  final String title;
  final String message;
  final String actionLabel;
}

class HomeDashboard {
  const HomeDashboard({
    required this.userName,
    required this.workspace,
    required this.networks,
    required this.metrics,
    required this.scheduledPosts,
    required this.recentPosts,
    required this.performanceTrend,
    required this.aiSuggestion,
    this.isDemo = true,
  });

  const HomeDashboard.empty({
    this.userName = 'Sarah',
    this.workspace = const HomeWorkspaceSummary(
      id: 'socialflow',
      name: 'Social Flow AI',
    ),
  }) : networks = const [],
       metrics = const [],
       scheduledPosts = const [],
       recentPosts = const [],
       performanceTrend = null,
       aiSuggestion = null,
       isDemo = true;

  final String userName;
  final HomeWorkspaceSummary workspace;
  final List<HomeNetworkSummary> networks;
  final List<HomeMetric> metrics;
  final List<HomeScheduledPost> scheduledPosts;
  final List<HomeRecentPost> recentPosts;
  final HomePerformanceTrend? performanceTrend;
  final HomeAiSuggestion? aiSuggestion;
  final bool isDemo;

  bool get isEmpty =>
      metrics.isEmpty && scheduledPosts.isEmpty && recentPosts.isEmpty;
}
