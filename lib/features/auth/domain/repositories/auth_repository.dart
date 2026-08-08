import '../entities/user_session.dart';

abstract interface class AuthRepository {
  Future<UserSession?> currentSession();
  Future<UserSession> login({required String email, required String password});
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
}
