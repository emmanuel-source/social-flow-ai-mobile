import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserSession?> currentSession() async {
    final token = LocalStorage.authToken;
    if (token == null) return null;
    return UserSession(
      userId: 'user-001',
      name: 'Sarah Miller',
      email: 'sarah@socialflow.ai',
      accessToken: token,
    );
  }

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (email.trim().isEmpty || password.length < 6) {
      throw const ValidationException(
        'Vérifiez votre e-mail et votre mot de passe.',
      );
    }
    const token = 'demo-access-token';
    await LocalStorage.setAuthToken(token);
    return UserSession(
      userId: 'user-001',
      name: 'Sarah Miller',
      email: email.trim(),
      accessToken: token,
    );
  }

  @override
  Future<void> logout() => LocalStorage.setAuthToken(null);
}
