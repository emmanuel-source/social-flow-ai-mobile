import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';

void main() {
  test('main navigation exposes exactly five routes in product order', () {
    expect(AppRoutes.mainRoutes, const [
      AppRoutes.home,
      AppRoutes.create,
      AppRoutes.calendar,
      AppRoutes.analytics,
      AppRoutes.profile,
    ]);
  });

  test('main routes and indexes have a bidirectional correspondence', () {
    for (var index = 0; index < AppRoutes.mainRoutes.length; index++) {
      final route = AppRoutes.mainRouteForIndex(index);
      expect(AppRoutes.mainIndexForRoute(route), index);
    }

    expect(AppRoutes.mainIndexForRoute('/unknown'), isNull);
  });

  test('secondary routes declare their owning main destination', () {
    expect(AppRoutes.parentRouteFor(AppRoutes.notifications), AppRoutes.home);
    expect(AppRoutes.parentRouteFor(AppRoutes.postDetail), AppRoutes.home);
    expect(AppRoutes.parentRouteFor(AppRoutes.postType), AppRoutes.create);
    expect(AppRoutes.parentRouteFor(AppRoutes.mediaLibrary), AppRoutes.create);
    expect(AppRoutes.parentRouteFor(AppRoutes.videoSource), AppRoutes.create);
    expect(AppRoutes.parentRouteFor(AppRoutes.aiAssistant), AppRoutes.create);
    expect(AppRoutes.parentRouteFor(AppRoutes.campaign), AppRoutes.create);
    expect(AppRoutes.parentRouteFor(AppRoutes.drafts), AppRoutes.create);
    expect(
      AppRoutes.parentRouteFor(AppRoutes.calendarDetail),
      AppRoutes.calendar,
    );
    expect(
      AppRoutes.parentRouteFor(AppRoutes.platformAnalytics),
      AppRoutes.analytics,
    );
    expect(AppRoutes.parentRouteFor(AppRoutes.workspaces), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.accounts), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.brandKit), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.agents), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.team), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.approvals), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.subscription), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.security), AppRoutes.profile);
    expect(AppRoutes.parentRouteFor(AppRoutes.settings), AppRoutes.profile);
  });
}
