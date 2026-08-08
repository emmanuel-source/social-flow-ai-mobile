import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialflow_ai/app/app_routes.dart';
import 'package:socialflow_ai/core/theme/app_theme.dart';
import 'package:socialflow_ai/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:socialflow_ai/features/auth/domain/entities/user_session.dart';
import 'package:socialflow_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:socialflow_ai/features/auth/presentation/controllers/auth_controller.dart';
import 'package:socialflow_ai/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets(
    'renders the initial login hierarchy without prefilled credentials',
    (tester) async {
      await _pumpLogin(tester);

      expect(find.text('Bon retour !'), findsOneWidget);
      expect(find.textContaining('Social Flow AI'), findsWidgets);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Créer un compte'), findsOneWidget);
      expect(_textField(tester, 'login-email-field').controller?.text, isEmpty);
      expect(
        _textField(tester, 'login-password-field').controller?.text,
        isEmpty,
      );
    },
  );

  testWidgets('configures the email field for email entry and autofill', (
    tester,
  ) async {
    await _pumpLogin(tester);

    final field = _textField(tester, 'login-email-field');
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.textInputAction, TextInputAction.next);
    expect(field.autofillHints, contains(AutofillHints.email));
  });

  testWidgets('configures the password field for secure autofill', (
    tester,
  ) async {
    await _pumpLogin(tester);

    final field = _textField(tester, 'login-password-field');
    expect(field.obscureText, isTrue);
    expect(field.autofillHints, contains(AutofillHints.password));
    expect(field.textInputAction, TextInputAction.done);
  });

  testWidgets('shows and hides the password with an accessible control', (
    tester,
  ) async {
    await _pumpLogin(tester);

    expect(_textField(tester, 'login-password-field').obscureText, isTrue);
    await tester.tap(find.byTooltip('Afficher le mot de passe'));
    await tester.pump();
    expect(_textField(tester, 'login-password-field').obscureText, isFalse);
    expect(find.byTooltip('Masquer le mot de passe'), findsOneWidget);
  });

  testWidgets('validates an empty email', (tester) async {
    await _pumpLogin(tester);
    await tester.enterText(_field('login-password-field'), 'password');

    await _submit(tester);

    expect(find.text("L'adresse e-mail est obligatoire."), findsOneWidget);
  });

  testWidgets('validates an invalid email format', (tester) async {
    await _pumpLogin(tester);
    await tester.enterText(_field('login-email-field'), 'adresse-invalide');
    await tester.enterText(_field('login-password-field'), 'password');

    await _submit(tester);

    expect(find.text('Adresse e-mail invalide.'), findsOneWidget);
  });

  testWidgets('validates an empty password', (tester) async {
    await _pumpLogin(tester);
    await tester.enterText(_field('login-email-field'), 'user@example.com');

    await _submit(tester);

    expect(find.text('Le mot de passe est obligatoire.'), findsOneWidget);
  });

  testWidgets('submits normalized valid credentials to the repository', (
    tester,
  ) async {
    final repository = _TestAuthRepository();
    await _pumpLogin(tester, repository: repository, onLoginSuccess: () {});
    await tester.enterText(_field('login-email-field'), ' User@Example.com ');
    await tester.enterText(_field('login-password-field'), 'password');

    await _submit(tester, settle: true);

    expect(repository.loginCalls, 1);
    expect(repository.lastEmail, 'User@Example.com');
    expect(repository.lastPassword, 'password');
  });

  testWidgets('shows loading and disables form actions during submission', (
    tester,
  ) async {
    final repository = _TestAuthRepository(pending: Completer<UserSession>());
    await _pumpLogin(tester, repository: repository);
    await _enterValidCredentials(tester);

    await tester.tap(_submitButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(_textField(tester, 'login-email-field').enabled, isFalse);
    expect(_textField(tester, 'login-password-field').enabled, isFalse);
    expect(_filledButton(tester).onPressed, isNull);
  });

  testWidgets('prevents double submission', (tester) async {
    final completer = Completer<UserSession>();
    final repository = _TestAuthRepository(pending: completer);
    await _pumpLogin(tester, repository: repository);
    await _enterValidCredentials(tester);

    await tester.tap(_submitButton);
    await tester.tap(_submitButton);
    await tester.pump();

    expect(repository.loginCalls, 1);
    completer.complete(_session);
    await tester.pumpAndSettle();
  });

  testWidgets('shows a readable invalid credentials error', (tester) async {
    await _pumpLogin(
      tester,
      repository: MockAuthRepository(delay: Duration.zero),
    );
    await _enterValidCredentials(
      tester,
      email: MockAuthRepository.invalidCredentialsEmail,
    );

    await _submit(tester, settle: true);

    expect(find.text('E-mail ou mot de passe incorrect.'), findsOneWidget);
    expect(find.byKey(const Key('login-submission-error')), findsOneWidget);
  });

  testWidgets('shows a safe generic error instead of a raw exception', (
    tester,
  ) async {
    await _pumpLogin(
      tester,
      repository: _TestAuthRepository(error: StateError('technical detail')),
    );
    await _enterValidCredentials(tester);

    await _submit(tester, settle: true);

    expect(
      find.text('Une erreur est survenue. Veuillez réessayer.'),
      findsOneWidget,
    );
    expect(find.textContaining('technical detail'), findsNothing);
  });

  testWidgets('reports mock success through the injected success callback', (
    tester,
  ) async {
    var successCount = 0;
    await _pumpLogin(
      tester,
      repository: MockAuthRepository(delay: Duration.zero),
      onLoginSuccess: () => successCount++,
    );
    await _enterValidCredentials(tester);

    await _submit(tester, settle: true);

    expect(successCount, 1);
  });

  testWidgets('navigates to the central home route after default success', (
    tester,
  ) async {
    await _pumpLogin(
      tester,
      repository: MockAuthRepository(delay: Duration.zero),
    );
    await _enterValidCredentials(tester);

    await _submit(tester, settle: true);

    expect(find.text('Destination principale'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('exposes the create account secondary navigation action', (
    tester,
  ) async {
    var createAccountCalls = 0;
    await _pumpLogin(tester, onCreateAccount: () => createAccountCalls++);

    await tester.tap(find.byKey(const Key('login-create-account')));
    await tester.pump();

    expect(createAccountCalls, 1);
  });

  testWidgets('navigates to the central register route by default', (
    tester,
  ) async {
    await _pumpLogin(tester);

    await tester.tap(find.byKey(const Key('login-create-account')));
    await tester.pumpAndSettle();

    expect(find.text('Destination inscription'), findsOneWidget);
  });

  testWidgets('exposes the forgot password secondary action', (tester) async {
    var forgotPasswordCalls = 0;
    await _pumpLogin(tester, onForgotPassword: () => forgotPasswordCalls++);

    await tester.tap(find.byKey(const Key('login-forgot-password')));
    await tester.pump();

    expect(forgotPasswordCalls, 1);
  });

  testWidgets('remains usable at 320 logical pixels', (tester) async {
    await _pumpLogin(tester, size: const Size(320, 700));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('supports enlarged text without overflow', (tester) async {
    await _pumpLogin(tester, size: const Size(320, 700), textScaleFactor: 1.6);

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pump();
    expect(_submitButton, findsOneWidget);
  });

  testWidgets('renders with the light theme', (tester) async {
    await _pumpLogin(tester, themeMode: ThemeMode.light);

    final context = tester.element(find.byType(LoginScreen));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders with the dark theme', (tester) async {
    await _pumpLogin(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(LoginScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays scrollable with a simulated mobile keyboard', (
    tester,
  ) async {
    await _pumpLogin(tester, size: const Size(320, 640), keyboardInset: 280);

    await tester.showKeyboard(_field('login-password-field'));
    await tester.pump();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(_submitButton, findsOneWidget);
  });

  testWidgets('exposes essential login semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpLogin(tester);

    expect(find.bySemanticsLabel('Logo Social Flow AI'), findsOneWidget);
    expect(find.byTooltip('Afficher le mot de passe'), findsOneWidget);
    expect(find.bySemanticsLabel('Se connecter'), findsWidgets);

    semantics.dispose();
  });

  testWidgets('keeps social login placeholders visible and disabled', (
    tester,
  ) async {
    await _pumpLogin(tester);

    for (final label in ['Google', 'Facebook', 'Apple']) {
      final button = tester.widget<OutlinedButton>(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(button.onPressed, isNull);
    }
  });
}

const _session = UserSession(
  userId: 'test-user',
  name: 'Test User',
  email: 'user@example.com',
  accessToken: 'test-session',
);

final _submitButton = find.byKey(const Key('login-submit'));

Finder _field(String key) =>
    find.descendant(of: find.byKey(Key(key)), matching: find.byType(TextField));

TextField _textField(WidgetTester tester, String key) =>
    tester.widget<TextField>(_field(key));

FilledButton _filledButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.descendant(of: _submitButton, matching: find.byType(FilledButton)),
);

Future<void> _enterValidCredentials(
  WidgetTester tester, {
  String email = 'user@example.com',
}) async {
  await tester.enterText(_field('login-email-field'), email);
  await tester.enterText(_field('login-password-field'), 'password');
}

Future<void> _submit(WidgetTester tester, {bool settle = false}) async {
  await tester.tap(_submitButton);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  AuthRepository? repository,
  ThemeMode themeMode = ThemeMode.light,
  Size size = const Size(390, 844),
  double textScaleFactor = 1,
  double keyboardInset = 0,
  VoidCallback? onCreateAccount,
  VoidCallback? onForgotPassword,
  VoidCallback? onLoginSuccess,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          repository ?? MockAuthRepository(delay: Duration.zero),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScaleFactor),
                viewInsets: EdgeInsets.only(bottom: keyboardInset),
              ),
              child: child!,
            ),
        routes: {
          AppRoutes.home:
              (_) => const Scaffold(body: Text('Destination principale')),
          AppRoutes.register:
              (_) => const Scaffold(body: Text('Destination inscription')),
        },
        home: LoginScreen(
          onCreateAccount: onCreateAccount,
          onForgotPassword: onForgotPassword,
          onLoginSuccess: onLoginSuccess,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _TestAuthRepository implements AuthRepository {
  _TestAuthRepository({this.pending, this.error});

  final Completer<UserSession>? pending;
  final Object? error;
  int loginCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<UserSession?> currentSession() async => null;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    if (error case final error?) throw error;
    if (pending case final pending?) return pending.future;
    return _session;
  }

  @override
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  }) async => _session;

  @override
  Future<void> logout() async {}
}
