abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';

  // Main shell: exactly 5 UX destinations.
  static const home = '/home';
  static const create = '/create';
  static const calendar = '/calendar';
  static const analytics = '/analytics';
  static const profile = '/profile';

  static const mainRoutes = <String>[
    home,
    create,
    calendar,
    analytics,
    profile,
  ];

  static int? mainIndexForRoute(String? route) {
    final index = mainRoutes.indexOf(route ?? '');
    return index == -1 ? null : index;
  }

  static String mainRouteForIndex(int index) => mainRoutes[index];

  // Existing interactive prototype flows.
  static const postType = '/create/post-type';
  static const postMedia = '/create/media';
  static const postCaption = '/create/caption';
  static const postPlatforms = '/create/platforms';
  static const postAdapt = '/create/adapt';
  static const postPreview = '/create/preview';
  static const postPublish = '/create/publish';
  static const postSchedule = '/create/schedule';
  static const postSuccess = '/create/success';
  static const videoSource = '/video/source';
  static const youtubeImport = '/video/youtube';
  static const videoConfig = '/video/config';
  static const videoAnalysis = '/video/analysis';
  static const clips = '/video/clips';
  static const clipEditor = '/video/clip-editor';
  static const subtitles = '/video/subtitles';
  static const campaign = '/campaign';
  static const trends = '/trends';
  static const brandKit = '/brand-kit';
  static const calendarDetail = '/calendar/detail';
  static const postAnalytics = '/analytics/post';
  static const agents = '/agents';
  static const agentTemplates = '/agents/templates';
  static const agentConfig = '/agents/config';
  static const agentPermissions = '/agents/permissions';
  static const agentSchedule = '/agents/schedule';
  static const agentTest = '/agents/test';
  static const agentDetail = '/agents/detail';
  static const accounts = '/profile/accounts';
  static const settings = '/profile/settings';
  static const inbox = '/inbox';

  // Architecture future-ready modules.
  static const workspaces = '/workspaces';
  static const mediaLibrary = '/media-library';
  static const publishingQueue = '/publishing';
  static const drafts = '/drafts';
  static const aiAssistant = '/ai-assistant';
  static const notifications = '/notifications';
  static const team = '/team';
  static const approvals = '/approvals';
  static const subscription = '/subscription';
  static const security = '/security';

  // Reserved route contracts for secondary screens implemented in later tasks.
  static const postDetail = '/home/post';
  static const platformAnalytics = '/analytics/platform';

  static const secondaryParentRoutes = <String, String>{
    notifications: home,
    postDetail: home,
    postType: create,
    postMedia: create,
    postCaption: create,
    postPlatforms: create,
    postAdapt: create,
    postPreview: create,
    postPublish: create,
    postSchedule: create,
    postSuccess: create,
    mediaLibrary: create,
    videoSource: create,
    youtubeImport: create,
    videoConfig: create,
    videoAnalysis: create,
    clips: create,
    clipEditor: create,
    subtitles: create,
    aiAssistant: create,
    campaign: create,
    drafts: create,
    calendarDetail: calendar,
    postAnalytics: analytics,
    platformAnalytics: analytics,
    workspaces: profile,
    accounts: profile,
    brandKit: profile,
    agents: profile,
    team: profile,
    approvals: profile,
    subscription: profile,
    security: profile,
    settings: profile,
  };

  static String? parentRouteFor(String? route) => secondaryParentRoutes[route];
}
