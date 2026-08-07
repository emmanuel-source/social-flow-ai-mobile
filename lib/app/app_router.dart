import 'package:flutter/material.dart';

import '../core/storage/local_storage.dart';
import '../features/agents/presentation/screens/agent_config_screen.dart';
import '../features/agents/presentation/screens/agent_detail_screen.dart';
import '../features/agents/presentation/screens/agent_permissions_screen.dart';
import '../features/agents/presentation/screens/agent_schedule_screen.dart';
import '../features/agents/presentation/screens/agent_templates_screen.dart';
import '../features/agents/presentation/screens/agent_test_screen.dart';
import '../features/agents/presentation/screens/agents_screen.dart';
import '../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/analytics/presentation/screens/post_analytics_screen.dart';
import '../features/approvals/presentation/screens/approvals_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/brand_kit/presentation/screens/brand_kit_screen.dart';
import '../features/calendar/presentation/screens/calendar_detail_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/campaigns/presentation/screens/campaign_screen.dart';
import '../features/campaigns/presentation/screens/trends_screen.dart';
import '../features/content/presentation/screens/caption_screen.dart';
import '../features/content/presentation/screens/create_hub_screen.dart';
import '../features/content/presentation/screens/media_picker_screen.dart';
import '../features/content/presentation/screens/platforms_screen.dart';
import '../features/content/presentation/screens/post_preview_screen.dart';
import '../features/content/presentation/screens/post_schedule_screen.dart';
import '../features/content/presentation/screens/post_success_screen.dart';
import '../features/content/presentation/screens/post_type_screen.dart';
import '../features/drafts/presentation/screens/drafts_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/inbox/presentation/screens/inbox_screen.dart';
import '../features/media_library/presentation/screens/media_library_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
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
import 'app_routes.dart';
import 'app_shell.dart';

abstract final class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static String get initialRoute {
    if (!LocalStorage.onboardingCompleted) return AppRoutes.onboarding;
    return LocalStorage.authToken == null ? AppRoutes.login : AppRoutes.home;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      AppRoutes.onboarding => const OnboardingScreen(),
      AppRoutes.login => const LoginScreen(),
      AppRoutes.home => const AppShell(initialIndex: 0),
      AppRoutes.create => const AppShell(initialIndex: 1),
      AppRoutes.calendar => const AppShell(initialIndex: 2),
      AppRoutes.analytics => const AppShell(initialIndex: 3),
      AppRoutes.profile => const AppShell(initialIndex: 4),
      AppRoutes.postType => const PostTypeScreen(),
      AppRoutes.postMedia => const MediaPickerScreen(),
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
      _ => const HomeScreen(),
    };

    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}
