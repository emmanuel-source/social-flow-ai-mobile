import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_state_view.dart';
import '../controllers/calendar_controller.dart';
import '../widgets/calendar_content.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: calendar.when(
          loading:
              () => const AppLoader(
                key: Key('calendar-loading'),
                label: 'Chargement du calendrier éditorial',
              ),
          error:
              (error, stackTrace) => AppErrorState(
                key: const Key('calendar-error'),
                title: 'Le calendrier est indisponible',
                message: 'Impossible de charger votre planning pour le moment.',
                onRetry: ref.read(calendarControllerProvider.notifier).reload,
              ),
          data:
              (state) => CalendarContent(
                state: state,
                controller: ref.read(calendarControllerProvider.notifier),
                onCreate:
                    () => Navigator.pushNamed(context, AppRoutes.postType),
                onEntry:
                    () =>
                        Navigator.pushNamed(context, AppRoutes.calendarDetail),
              ),
        ),
      ),
    );
  }
}
