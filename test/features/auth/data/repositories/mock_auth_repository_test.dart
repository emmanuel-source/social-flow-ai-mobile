import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:socialflow_ai/features/auth/domain/entities/auth_failure.dart';

void main() {
  group('MockAuthRepository', () {
    test('keeps a successful mock session in memory only', () async {
      final repository = MockAuthRepository(delay: Duration.zero);

      final session = await repository.login(
        email: 'User@Example.com ',
        password: 'password',
      );

      expect(session.email, 'user@example.com');
      expect(await repository.currentSession(), same(session));

      await repository.logout();
      expect(await repository.currentSession(), isNull);
    });

    test('simulates invalid credentials', () async {
      final repository = MockAuthRepository(delay: Duration.zero);

      expect(
        repository.login(
          email: MockAuthRepository.invalidCredentialsEmail,
          password: 'password',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (error) => error.type,
            'type',
            AuthFailureType.invalidCredentials,
          ),
        ),
      );
    });

    test('simulates a generic failure', () async {
      final repository = MockAuthRepository(delay: Duration.zero);

      expect(
        repository.login(
          email: MockAuthRepository.genericErrorEmail,
          password: 'password',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (error) => error.type,
            'type',
            AuthFailureType.generic,
          ),
        ),
      );
    });
  });
}
