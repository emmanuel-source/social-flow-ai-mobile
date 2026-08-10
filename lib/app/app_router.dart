import 'package:flutter/material.dart';

import '../core/storage/local_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_sizes.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../features/agents/presentation/screens/agent_config_screen.dart';
import '../features/agents/presentation/screens/agent_detail_screen.dart';
import '../features/agents/presentation/screens/agent_permissions_screen.dart';
import '../features/agents/presentation/screens/agent_schedule_screen.dart';
import '../features/agents/presentation/screens/agent_templates_screen.dart';
import '../features/agents/presentation/screens/agent_test_screen.dart';
import '../features/agents/presentation/screens/agents_screen.dart';
import '../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../features/analytics/presentation/screens/post_analytics_screen.dart';
import '../features/approvals/presentation/screens/approvals_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/brand_kit/presentation/screens/brand_kit_screen.dart';
import '../features/calendar/presentation/screens/calendar_detail_screen.dart';
import '../features/campaigns/presentation/screens/campaign_screen.dart';
import '../features/campaigns/presentation/screens/trends_screen.dart';
import '../features/content/presentation/screens/caption_screen.dart';
import '../features/content/presentation/screens/composer_screen.dart';
import '../features/content/presentation/screens/platforms_screen.dart';
import '../features/content/presentation/screens/post_preview_screen.dart';
import '../features/content/presentation/screens/post_schedule_screen.dart';
import '../features/content/presentation/screens/post_success_screen.dart';
import '../features/content/presentation/screens/post_type_screen.dart';
import '../features/drafts/presentation/screens/drafts_screen.dart';
import '../features/inbox/presentation/screens/inbox_screen.dart';
import '../features/media_library/presentation/screens/media_library_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/publishing/presentation/screens/publishing_queue_screen.dart';
import '../features/security/presentation/screens/security_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/social_accounts/presentation/screens/social_accounts_screen.dart';
import '../features/subscriptions/presentation/screens/subscription_screen.dart';
import '../features/team/presentation/screens/team_screen.dart';
import '../features/video_studio/presentation/screens/clip_editor_screen.dart';
import '../features/video_studio/presentation/screens/clips_screen.dart';
import '../features/video_studio/presentation/screens/subtitles_screen.dart';
import '../features/video_studio/presentation/screens/video_analysis_screen.dart';
import '../features/video_studio/presentation/screens/video_config_screen.dart';
import '../features/video_studio/presentation/screens/video_source_screen.dart';
import '../features/video_studio/presentation/screens/youtube_import_screen.dart';
import '../features/workspaces/presentation/screens/workspaces_screen.dart';
import '../shared/widgets/app_buttons.dart';
import 'app_routes.dart';
import 'app_shell.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final navigatorObservers = <NavigatorObserver>[MainRouteObserver()];

  static String get initialRoute {
    final platformRoute =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    if (platformRoute != Navigator.defaultRouteName) return platformRoute;
    if (!LocalStorage.onboardingCompleted) return AppRoutes.onboarding;
    return LocalStorage.authToken == null ? AppRoutes.login : AppRoutes.home;
  }

  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
    onGenerateRoute(RouteSettings(name: initialRoute)),
  ];

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final mainIndex = AppRoutes.mainIndexForRoute(routeName);
    final page =
        mainIndex != null
            ? AppShell(initialRoute: routeName!)
            : switch (routeName) {
              AppRoutes.onboarding => const OnboardingScreen(),
              AppRoutes.login => const LoginScreen(),
              AppRoutes.register => const RegisterScreen(),
              AppRoutes.postType => const PostTypeScreen(),
              AppRoutes.postMedia => const ComposerScreen(),
              AppRoutes.postCaption => const CaptionScreen(),
              AppRoutes.postPlatforms => const PlatformsScreen(),
              AppRoutes.postPreview => const PostPreviewScreen(),
              AppRoutes.postSchedule => const PostScheduleScreen(),
              AppRoutes.postSuccess => const PostSuccessScreen(),
              AppRoutes.videoSource => const VideoSourceScreen(),
              AppRoutes.youtubeImport => const YoutubeImportScreen(),
              AppRoutes.videoConfig => const VideoConfigScreen(),
              AppRoutes.videoAnalysis => const VideoAnalysisScreen(),
              AppRoutes.clips => const ClipsScreen(),
              AppRoutes.clipEditor => const ClipEditorScreen(),
              AppRoutes.subtitles => const SubtitlesScreen(),
              AppRoutes.campaign => const CampaignScreen(),
              AppRoutes.trends => const TrendsScreen(),
              AppRoutes.brandKit => const BrandKitScreen(),
              AppRoutes.calendarDetail => const CalendarDetailScreen(),
              AppRoutes.postAnalytics => const PostAnalyticsScreen(),
              AppRoutes.agents => const AgentsScreen(),
              AppRoutes.agentTemplates => const AgentTemplatesScreen(),
              AppRoutes.agentConfig => const AgentConfigScreen(),
              AppRoutes.agentPermissions => const AgentPermissionsScreen(),
              AppRoutes.agentSchedule => const AgentScheduleScreen(),
              AppRoutes.agentTest => const AgentTestScreen(),
              AppRoutes.agentDetail => const AgentDetailScreen(),
              AppRoutes.accounts => const SocialAccountsScreen(),
              AppRoutes.settings => const SettingsScreen(),
              AppRoutes.inbox => const InboxScreen(),
              AppRoutes.workspaces => const WorkspacesScreen(),
              AppRoutes.mediaLibrary => const MediaLibraryScreen(),
              AppRoutes.publishingQueue => const PublishingQueueScreen(),
              AppRoutes.drafts => const DraftsScreen(),
              AppRoutes.aiAssistant => const AiAssistantScreen(),
              AppRoutes.notifications => const NotificationsScreen(),
              AppRoutes.team => const TeamScreen(),
              AppRoutes.approvals => const ApprovalsScreen(),
              AppRoutes.subscription => const SubscriptionScreen(),
              AppRoutes.security => const SecurityScreen(),
              _ => UnknownRouteScreen(routeName: routeName),
            };

    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}

class MainRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (previousRoute == null ||
        AppRoutes.mainIndexForRoute(route.settings.name) == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (previousRoute.isActive) {
        navigator?.removeRoute(previousRoute);
      }
    });
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({required this.routeName, super.key});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final canGoBack = navigator.canPop();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenInsets,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.contentMaxWidth,
              ),
              child: Semantics(
                container: true,
                label: 'Route inconnue',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.route_outlined,
                      size: AppSizes.iconHero,
                      color: AppColors.brandPrimary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Page introuvable',
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'La route ${routeName ?? 'demandée'} n’est pas disponible.',
                      textAlign: TextAlign.center,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppSecondaryButton(
                      label: canGoBack ? 'Retour' : 'Retour à l’accueil',
                      icon: Icons.arrow_back,
                      onPressed: () {
                        if (canGoBack) {
                          navigator.pop();
                        } else {
                          navigator.pushReplacementNamed(AppRoutes.home);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
