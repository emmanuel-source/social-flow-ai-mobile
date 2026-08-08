import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_home_repository.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => const MockHomeRepository(),
);

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeDashboard>(HomeController.new);

class HomeController extends AsyncNotifier<HomeDashboard> {
  @override
  Future<HomeDashboard> build() =>
      ref.watch(homeRepositoryProvider).fetchDashboard();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(homeRepositoryProvider).fetchDashboard,
    );
  }
}
