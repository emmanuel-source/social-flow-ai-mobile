import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserSession?>(AuthController.new);

class AuthController extends AsyncNotifier<UserSession?> {
  @override
  Future<UserSession?> build() =>
      ref.read(authRepositoryProvider).currentSession();

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      state = AsyncData(session);
      return true;
    } on AuthFailure catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    } catch (_, stackTrace) {
      const error = AuthFailure.generic();
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
