import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/home/data/repositories/mock_home_repository.dart';

void main() {
  test('returns an explicitly demo-labelled dashboard projection', () async {
    const repository = MockHomeRepository(delay: Duration.zero);

    final dashboard = await repository.fetchDashboard();

    expect(dashboard.isDemo, isTrue);
    expect(dashboard.workspace.name, 'Social Flow AI');
    expect(dashboard.networks, hasLength(4));
    expect(dashboard.metrics, hasLength(4));
    expect(dashboard.scheduledPosts, hasLength(3));
    expect(dashboard.recentPosts, hasLength(2));
    expect(dashboard.aiSuggestion, isNotNull);
  });
}
