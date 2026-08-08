import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/deep_links/deep_link_parser.dart';
import '../core/deep_links/deep_link_service.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/presentation/controllers/theme_controller.dart';
import 'app_router.dart';

class SocialFlowApp extends ConsumerStatefulWidget {
  const SocialFlowApp({super.key});

  @override
  ConsumerState<SocialFlowApp> createState() => _SocialFlowAppState();
}

class _SocialFlowAppState extends ConsumerState<SocialFlowApp> {
  final DeepLinkService _deepLinkService = DeepLinkService();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _linkSubscription = _deepLinkService.start(_openDeepLink);
  }

  void _openDeepLink(Uri uri) {
    final target = DeepLinkParser.parse(uri);
    if (target == null) return;
    AppRouter.navigatorKey.currentState?.pushNamed(
      target.route,
      arguments: target.arguments,
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'SocialFlow AI',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.navigatorKey,
      navigatorObservers: AppRouter.navigatorObservers,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: AppRouter.initialRoute,
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
