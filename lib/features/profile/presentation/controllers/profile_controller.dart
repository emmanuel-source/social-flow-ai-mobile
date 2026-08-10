import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_profile_repository.dart';
import '../../domain/entities/profile_overview.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => const MockProfileRepository(),
);

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileOverview>(
      ProfileController.new,
    );

class ProfileController extends AsyncNotifier<ProfileOverview> {
  @override
  Future<ProfileOverview> build() =>
      ref.watch(profileRepositoryProvider).fetchOverview();

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).fetchOverview(),
    );
  }
}
