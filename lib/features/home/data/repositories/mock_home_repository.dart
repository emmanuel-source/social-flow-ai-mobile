import '../../../../shared/models/social_platform.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_repository.dart';

class MockHomeRepository implements HomeRepository {
  const MockHomeRepository({
    this.delay = const Duration(milliseconds: 450),
    this.dashboard = demoDashboard,
  });

  final Duration delay;
  final HomeDashboard dashboard;

  @override
  Future<HomeDashboard> fetchDashboard() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return dashboard;
  }

  static const demoDashboard = HomeDashboard(
    userName: 'Sarah',
    workspace: HomeWorkspaceSummary(id: 'socialflow', name: 'Social Flow AI'),
    networks: [
      HomeNetworkSummary(platform: SocialPlatform.instagram, connected: true),
      HomeNetworkSummary(platform: SocialPlatform.facebook, connected: true),
      HomeNetworkSummary(platform: SocialPlatform.tiktok, connected: true),
      HomeNetworkSummary(platform: SocialPlatform.youtube, connected: true),
    ],
    metrics: [
      HomeMetric(
        type: HomeMetricType.views,
        label: 'Vues',
        value: '124,8 K',
        trend: '+18,6 %',
      ),
      HomeMetric(
        type: HomeMetricType.engagement,
        label: 'Engagement',
        value: '8,4 %',
        trend: '+1,2 pt',
      ),
      HomeMetric(
        type: HomeMetricType.followers,
        label: 'Nouveaux abonnés',
        value: '+1 284',
        trend: '+12 %',
      ),
      HomeMetric(
        type: HomeMetricType.publications,
        label: 'Publications',
        value: '18',
        trend: '+3',
      ),
    ],
    scheduledPosts: [
      HomeScheduledPost(
        id: 'scheduled-instagram',
        title: '5 idées pour une semaine plus productive',
        platform: SocialPlatform.instagram,
        scheduleLabel: 'Aujourd’hui · 18:30',
        contentType: 'Carrousel',
        status: HomePublicationStatus.scheduled,
      ),
      HomeScheduledPost(
        id: 'scheduled-tiktok',
        title: 'Les coulisses du podcast #12',
        platform: SocialPlatform.tiktok,
        scheduleLabel: 'Demain · 10:00',
        contentType: 'Vidéo',
        status: HomePublicationStatus.review,
      ),
      HomeScheduledPost(
        id: 'scheduled-linkedin',
        title: 'Les 3 tendances social media à suivre',
        platform: SocialPlatform.linkedin,
        scheduleLabel: 'Lundi · 08:15',
        contentType: 'Texte',
        status: HomePublicationStatus.scheduled,
      ),
    ],
    recentPosts: [
      HomeRecentPost(
        id: 'recent-instagram',
        title: 'Notre méthode pour créer sans s’épuiser',
        platform: SocialPlatform.instagram,
        preview: 'Publié hier · Carrousel',
        status: HomePublicationStatus.published,
        primaryMetric: '42,8 K vues',
      ),
      HomeRecentPost(
        id: 'recent-youtube',
        title: 'Construire une stratégie éditoriale durable',
        platform: SocialPlatform.youtube,
        preview: 'Publié il y a 3 jours · Vidéo',
        status: HomePublicationStatus.published,
        primaryMetric: '9,7 % engagement',
      ),
    ],
    performanceTrend: HomePerformanceTrend(
      label: 'Portée sur les 7 derniers jours',
      change: '+18,6 %',
      points: [42, 48, 45, 57, 61, 72, 78],
    ),
    aiSuggestion: HomeAiSuggestion(
      title: 'Votre meilleur créneau se confirme',
      message:
          'Vos contenus obtiennent le plus d’engagement le mardi entre 18 h et 20 h.',
      actionLabel: 'Créer pour ce créneau',
    ),
  );
}
