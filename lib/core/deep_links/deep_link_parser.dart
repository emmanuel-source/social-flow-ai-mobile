import '../../app/app_routes.dart';

class DeepLinkTarget {
  const DeepLinkTarget(this.route, {this.arguments});

  final String route;
  final Object? arguments;
}

abstract final class DeepLinkParser {
  static DeepLinkTarget? parse(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return const DeepLinkTarget(AppRoutes.home);

    return switch (segments.first) {
      'post' => DeepLinkTarget(
          AppRoutes.postAnalytics,
          arguments: segments.length > 1 ? segments[1] : null,
        ),
      'calendar' => DeepLinkTarget(
          AppRoutes.calendarDetail,
          arguments: segments.length > 1 ? segments[1] : null,
        ),
      'agent' => DeepLinkTarget(
          AppRoutes.agentDetail,
          arguments: segments.length > 1 ? segments[1] : null,
        ),
      'create' => const DeepLinkTarget(AppRoutes.create),
      'inbox' => const DeepLinkTarget(AppRoutes.inbox),
      _ => const DeepLinkTarget(AppRoutes.home),
    };
  }
}
