import '../../../../shared/models/social_platform.dart';
import '../../domain/entities/analytics_dashboard.dart';
import '../../domain/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  MockAnalyticsRepository({
    this.delay = const Duration(milliseconds: 400),
    Map<AnalyticsPeriod, AnalyticsDashboard>? dashboards,
  }) : dashboards = dashboards ?? demoDashboards;

  final Duration delay;
  final Map<AnalyticsPeriod, AnalyticsDashboard> dashboards;

  @override
  Future<AnalyticsDashboard> fetchDashboard(AnalyticsPeriod period) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return dashboards[period] ?? AnalyticsDashboard.empty(period: period);
  }

  static final demoDashboards = <AnalyticsPeriod, AnalyticsDashboard>{
    AnalyticsPeriod.sevenDays: AnalyticsDashboard(
      period: AnalyticsPeriod.sevenDays,
      workspaceName: 'Social Flow AI',
      kpis: const [
        AnalyticsKpi(
          type: AnalyticsKpiType.views,
          label: 'Vues',
          value: '32,4 K',
          change: '+9,8 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 7 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.engagement,
          label: 'Engagement',
          value: '8,9 %',
          change: '+0,8 pt',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 7 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.followers,
          label: 'Nouveaux abonnés',
          value: '+346',
          change: '+6,1 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 7 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.interactions,
          label: 'Interactions',
          value: '4,7 K',
          change: '-2,4 %',
          direction: AnalyticsTrendDirection.negative,
          comparisonLabel: 'vs les 7 jours précédents',
        ),
      ],
      viewsSeries: _sevenDaySeries,
      platforms: _sevenDayPlatforms,
      topContents: _sevenDayTopContents,
      insight: const AnalyticsInsight(
        title: 'Le format court prend l’avantage',
        message:
            'Vos Reels publiés entre 18 h et 20 h obtiennent actuellement le meilleur engagement.',
      ),
    ),
    AnalyticsPeriod.thirtyDays: AnalyticsDashboard(
      period: AnalyticsPeriod.thirtyDays,
      workspaceName: 'Social Flow AI',
      kpis: const [
        AnalyticsKpi(
          type: AnalyticsKpiType.views,
          label: 'Vues',
          value: '124,8 K',
          change: '+18,2 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 30 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.engagement,
          label: 'Engagement',
          value: '8,4 %',
          change: '+1,3 pt',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 30 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.followers,
          label: 'Nouveaux abonnés',
          value: '+1 284',
          change: '+12 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 30 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.interactions,
          label: 'Interactions',
          value: '18,6 K',
          change: '+9,4 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 30 jours précédents',
        ),
      ],
      viewsSeries: _thirtyDaySeries,
      platforms: _thirtyDayPlatforms,
      topContents: _thirtyDayTopContents,
      insight: const AnalyticsInsight(
        title: 'Votre meilleur créneau se confirme',
        message:
            'Les contenus publiés entre 18 h et 20 h génèrent 24 % d’interactions supplémentaires.',
      ),
    ),
    AnalyticsPeriod.ninetyDays: AnalyticsDashboard(
      period: AnalyticsPeriod.ninetyDays,
      workspaceName: 'Social Flow AI',
      kpis: const [
        AnalyticsKpi(
          type: AnalyticsKpiType.views,
          label: 'Vues',
          value: '368,2 K',
          change: '+26,4 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 90 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.engagement,
          label: 'Engagement',
          value: '8,1 %',
          change: '+0,6 pt',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 90 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.followers,
          label: 'Nouveaux abonnés',
          value: '+3 742',
          change: '+19,7 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 90 jours précédents',
        ),
        AnalyticsKpi(
          type: AnalyticsKpiType.interactions,
          label: 'Interactions',
          value: '53,1 K',
          change: '+14,8 %',
          direction: AnalyticsTrendDirection.positive,
          comparisonLabel: 'vs les 90 jours précédents',
        ),
      ],
      viewsSeries: _ninetyDaySeries,
      platforms: _ninetyDayPlatforms,
      topContents: _ninetyDayTopContents,
      insight: const AnalyticsInsight(
        title: 'Une croissance durable',
        message:
            'La régularité de publication améliore vos vues sur trois mois, particulièrement sur Instagram et YouTube.',
      ),
    ),
  };

  static final _sevenDaySeries = _series(7, const [
    3.2,
    4.1,
    3.8,
    5.0,
    4.7,
    5.6,
    6.0,
  ]);
  static final _thirtyDaySeries = _series(15, const [
    5.4,
    6.1,
    5.8,
    7.2,
    7.7,
    7.3,
    8.9,
    9.4,
    8.8,
    10.2,
    10.9,
    10.5,
    11.8,
    11.3,
    12.7,
  ], stepDays: 2);
  static final _ninetyDaySeries = _series(18, const [
    8.1,
    8.8,
    9.4,
    10.1,
    9.7,
    11.2,
    12.0,
    12.8,
    12.4,
    13.9,
    14.6,
    15.1,
    16.0,
    15.7,
    17.2,
    18.0,
    18.8,
    19.6,
  ], stepDays: 5);

  static const _sevenDayPlatforms = [
    PlatformPerformance(
      platform: SocialPlatform.instagram,
      views: '13,8 K',
      engagement: '10,2 %',
      change: '+12,1 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.tiktok,
      views: '9,6 K',
      engagement: '9,4 %',
      change: '+7,8 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.youtube,
      views: '5,4 K',
      engagement: '6,8 %',
      change: '-1,2 %',
      direction: AnalyticsTrendDirection.negative,
    ),
    PlatformPerformance(
      platform: SocialPlatform.linkedin,
      views: '3,6 K',
      engagement: '5,1 %',
      change: '+3,2 %',
      direction: AnalyticsTrendDirection.positive,
    ),
  ];
  static const _thirtyDayPlatforms = [
    PlatformPerformance(
      platform: SocialPlatform.instagram,
      views: '48,7 K',
      engagement: '10,1 %',
      change: '+22,4 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.tiktok,
      views: '34,2 K',
      engagement: '9,2 %',
      change: '+16,8 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.youtube,
      views: '27,5 K',
      engagement: '6,9 %',
      change: '+11,3 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.facebook,
      views: '14,4 K',
      engagement: '5,4 %',
      change: '-3,1 %',
      direction: AnalyticsTrendDirection.negative,
    ),
  ];
  static const _ninetyDayPlatforms = [
    PlatformPerformance(
      platform: SocialPlatform.instagram,
      views: '142,6 K',
      engagement: '9,8 %',
      change: '+31,2 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.youtube,
      views: '91,4 K',
      engagement: '7,4 %',
      change: '+28,6 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.tiktok,
      views: '88,9 K',
      engagement: '8,8 %',
      change: '+18,5 %',
      direction: AnalyticsTrendDirection.positive,
    ),
    PlatformPerformance(
      platform: SocialPlatform.facebook,
      views: '45,3 K',
      engagement: '5,2 %',
      change: '+4,1 %',
      direction: AnalyticsTrendDirection.positive,
    ),
  ];

  static const _sevenDayTopContents = [
    TopContentPerformance(
      id: 'reel-productivity',
      rank: 1,
      platform: SocialPlatform.instagram,
      contentType: 'Reel',
      title: '3 idées pour créer sans s’épuiser',
      primaryMetric: '12,4 K vues',
      engagement: '11,8 % engagement',
    ),
    TopContentPerformance(
      id: 'tiktok-podcast',
      rank: 2,
      platform: SocialPlatform.tiktok,
      contentType: 'Vidéo',
      title: 'Les coulisses du podcast #12',
      primaryMetric: '8,9 K vues',
      engagement: '10,3 % engagement',
    ),
  ];
  static const _thirtyDayTopContents = [
    TopContentPerformance(
      id: 'carousel-method',
      rank: 1,
      platform: SocialPlatform.instagram,
      contentType: 'Carrousel',
      title: 'Notre méthode pour créer sans s’épuiser',
      primaryMetric: '42,8 K vues',
      engagement: '12,1 % engagement',
    ),
    TopContentPerformance(
      id: 'youtube-strategy',
      rank: 2,
      platform: SocialPlatform.youtube,
      contentType: 'Vidéo',
      title: 'Construire une stratégie éditoriale durable',
      primaryMetric: '31,6 K vues',
      engagement: '9,7 % engagement',
    ),
    TopContentPerformance(
      id: 'linkedin-trends',
      rank: 3,
      platform: SocialPlatform.linkedin,
      contentType: 'Post',
      title: 'Les tendances social media à suivre',
      primaryMetric: '18,4 K impressions',
      engagement: '7,6 % engagement',
    ),
  ];
  static const _ninetyDayTopContents = [
    TopContentPerformance(
      id: 'youtube-guide',
      rank: 1,
      platform: SocialPlatform.youtube,
      contentType: 'Vidéo',
      title: 'Le guide complet de la stratégie sociale',
      primaryMetric: '76,2 K vues',
      engagement: '10,8 % engagement',
    ),
    TopContentPerformance(
      id: 'instagram-checklist',
      rank: 2,
      platform: SocialPlatform.instagram,
      contentType: 'Carrousel',
      title: 'La checklist du créateur efficace',
      primaryMetric: '64,7 K vues',
      engagement: '12,4 % engagement',
    ),
    TopContentPerformance(
      id: 'tiktok-routine',
      rank: 3,
      platform: SocialPlatform.tiktok,
      contentType: 'Vidéo',
      title: 'Routine du matin productive',
      primaryMetric: '51,3 K vues',
      engagement: '9,9 % engagement',
    ),
  ];

  static List<AnalyticsTimePoint> _series(
    int count,
    List<double> values, {
    int stepDays = 1,
  }) => [
    for (var index = 0; index < count; index++)
      AnalyticsTimePoint(
        date: DateTime(2026, 7, 1).add(Duration(days: index * stepDays)),
        value: values[index],
      ),
  ];
}
