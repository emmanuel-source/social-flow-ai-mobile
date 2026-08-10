import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/analytics/data/repositories/mock_analytics_repository.dart';
import 'package:socialflow_ai/features/analytics/domain/entities/analytics_dashboard.dart';

void main() {
  late MockAnalyticsRepository repository;

  setUp(() {
    repository = MockAnalyticsRepository(delay: Duration.zero);
  });

  for (final period in AnalyticsPeriod.values) {
    test('returns a complete ${period.name} dashboard', () async {
      final dashboard = await repository.fetchDashboard(period);

      expect(dashboard.period, period);
      expect(dashboard.kpis, hasLength(4));
      expect(dashboard.viewsSeries, isNotEmpty);
      expect(dashboard.platforms, isNotEmpty);
      expect(dashboard.topContents, isNotEmpty);
      expect(dashboard.insight, isNotNull);
    });
  }

  test('30 day dataset exposes the agreed product metrics', () async {
    final dashboard = await repository.fetchDashboard(
      AnalyticsPeriod.thirtyDays,
    );

    expect(dashboard.kpis.map((kpi) => kpi.value), [
      '124,8 K',
      '8,4 %',
      '+1 284',
      '18,6 K',
    ]);
  });

  test('time series contain enough points for useful charts', () async {
    final seven = await repository.fetchDashboard(AnalyticsPeriod.sevenDays);
    final thirty = await repository.fetchDashboard(AnalyticsPeriod.thirtyDays);
    final ninety = await repository.fetchDashboard(AnalyticsPeriod.ninetyDays);

    expect(seven.viewsSeries, hasLength(7));
    expect(thirty.viewsSeries.length, greaterThanOrEqualTo(14));
    expect(ninety.viewsSeries.length, greaterThanOrEqualTo(18));
  });

  test('datasets model positive and negative trends explicitly', () async {
    final dashboard = await repository.fetchDashboard(
      AnalyticsPeriod.sevenDays,
    );

    expect(
      dashboard.kpis.any(
        (kpi) => kpi.direction == AnalyticsTrendDirection.positive,
      ),
      isTrue,
    );
    expect(
      dashboard.kpis.any(
        (kpi) => kpi.direction == AnalyticsTrendDirection.negative,
      ),
      isTrue,
    );
  });

  test('missing mock period falls back to an empty dashboard', () async {
    final emptyRepository = MockAnalyticsRepository(
      delay: Duration.zero,
      dashboards: const {},
    );

    final dashboard = await emptyRepository.fetchDashboard(
      AnalyticsPeriod.thirtyDays,
    );
    expect(dashboard.isEmpty, isTrue);
    expect(dashboard.period, AnalyticsPeriod.thirtyDays);
  });
}
