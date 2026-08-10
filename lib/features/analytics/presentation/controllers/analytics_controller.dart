import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_analytics_repository.dart';
import '../../domain/entities/analytics_dashboard.dart';
import '../../domain/repositories/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => MockAnalyticsRepository(),
);

final analyticsControllerProvider =
    AsyncNotifierProvider<AnalyticsController, AnalyticsDashboard>(
      AnalyticsController.new,
    );

class AnalyticsController extends AsyncNotifier<AnalyticsDashboard> {
  AnalyticsPeriod _period = AnalyticsPeriod.thirtyDays;

  AnalyticsPeriod get period => _period;

  @override
  Future<AnalyticsDashboard> build() =>
      ref.watch(analyticsRepositoryProvider).fetchDashboard(_period);

  Future<void> selectPeriod(AnalyticsPeriod period) async {
    if (period == _period && state.hasValue) return;
    _period = period;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(analyticsRepositoryProvider).fetchDashboard(_period),
    );
  }

  Future<void> reload() => selectPeriod(_period);
}
