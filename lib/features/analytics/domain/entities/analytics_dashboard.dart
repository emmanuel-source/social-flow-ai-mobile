import '../../../../shared/models/social_platform.dart';

enum AnalyticsPeriod { sevenDays, thirtyDays, ninetyDays }

enum AnalyticsKpiType { views, engagement, followers, interactions }

enum AnalyticsTrendDirection { positive, negative, neutral }

class AnalyticsKpi {
  const AnalyticsKpi({
    required this.type,
    required this.label,
    required this.value,
    required this.change,
    required this.direction,
    required this.comparisonLabel,
  });

  final AnalyticsKpiType type;
  final String label;
  final String value;
  final String change;
  final AnalyticsTrendDirection direction;
  final String comparisonLabel;
}

class AnalyticsTimePoint {
  const AnalyticsTimePoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class PlatformPerformance {
  const PlatformPerformance({
    required this.platform,
    required this.views,
    required this.engagement,
    required this.change,
    required this.direction,
  });

  final SocialPlatform platform;
  final String views;
  final String engagement;
  final String change;
  final AnalyticsTrendDirection direction;
}

class TopContentPerformance {
  const TopContentPerformance({
    required this.id,
    required this.rank,
    required this.platform,
    required this.contentType,
    required this.title,
    required this.primaryMetric,
    required this.engagement,
  });

  final String id;
  final int rank;
  final SocialPlatform platform;
  final String contentType;
  final String title;
  final String primaryMetric;
  final String engagement;
}

class AnalyticsInsight {
  const AnalyticsInsight({required this.title, required this.message});

  final String title;
  final String message;
}

class AnalyticsDashboard {
  const AnalyticsDashboard({
    required this.period,
    required this.workspaceName,
    required this.kpis,
    required this.viewsSeries,
    required this.platforms,
    required this.topContents,
    required this.insight,
    this.isDemo = true,
  });

  const AnalyticsDashboard.empty({
    required this.period,
    this.workspaceName = 'Social Flow AI',
  }) : kpis = const [],
       viewsSeries = const [],
       platforms = const [],
       topContents = const [],
       insight = null,
       isDemo = true;

  final AnalyticsPeriod period;
  final String workspaceName;
  final List<AnalyticsKpi> kpis;
  final List<AnalyticsTimePoint> viewsSeries;
  final List<PlatformPerformance> platforms;
  final List<TopContentPerformance> topContents;
  final AnalyticsInsight? insight;
  final bool isDemo;

  bool get isEmpty =>
      kpis.isEmpty &&
      viewsSeries.isEmpty &&
      platforms.isEmpty &&
      topContents.isEmpty;
}
