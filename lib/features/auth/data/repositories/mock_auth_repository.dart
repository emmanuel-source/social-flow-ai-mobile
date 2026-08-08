import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.delay = const Duration(milliseconds: 650)});

  static const invalidCredentialsEmail = 'invalid@socialflow.ai';
  static const genericErrorEmail = 'error@socialflow.ai';
  static const registeredEmail = 'used@socialflow.ai';
  static const registrationErrorEmail = 'register-error@socialflow.ai';

  final Duration delay;
  UserSession? _session;

  @override
  Future<UserSession?> currentSession() async => _session;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == invalidCredentialsEmail) {
      throw const AuthFailure.invalidCredentials();
    }
    if (normalizedEmail == genericErrorEmail) {
      throw const AuthFailure.generic();
    }

    _session = UserSession(
      userId: 'user-001',
      name: 'Sarah Miller',
      email: normalizedEmail,
      accessToken: 'mock-session-not-persisted',
    );
    return _session!;
  }

  @override
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(delay);
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail == registeredEmail) {
      throw const AuthFailure.emailAlreadyUsed();
    }
    if (normalizedEmail == registrationErrorEmail) {
      throw const AuthFailure.generic();
    }

    _session = UserSession(
      userId: 'user-registered',
      name: name.trim(),
      email: normalizedEmail,
      accessToken: 'mock-session-not-persisted',
    );
    return _session!;
  }

  @override
  Future<void> logout() async => _session = null;
}
