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
import 'package:socialflow_ai/features/auth/presentation/screens/register_screen.dart';
import 'package:socialflow_ai/shared/widgets/app_selection_controls.dart';

void main() {
  testWidgets('renders the initial registration hierarchy', (tester) async {
    await _pumpRegister(tester);

    expect(find.text('Créez votre compte'), findsOneWidget);
    expect(find.text('Créer mon compte'), findsOneWidget);
    expect(find.text('Déjà un compte ?'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('configures the full name field for name autofill', (
    tester,
  ) async {
    await _pumpRegister(tester);

    final field = _textField(tester, 'register-name-field');
    expect(field.autofillHints, contains(AutofillHints.name));
    expect(field.textInputAction, TextInputAction.next);
  });

  testWidgets('configures the email field for email entry and autofill', (
    tester,
  ) async {
    await _pumpRegister(tester);

    final field = _textField(tester, 'register-email-field');
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.autofillHints, contains(AutofillHints.email));
  });

  testWidgets('configures the password field as obscured', (tester) async {
    await _pumpRegister(tester);

    final field = _textField(tester, 'register-password-field');
    expect(field.obscureText, isTrue);
    expect(field.autofillHints, contains(AutofillHints.password));
    expect(find.textContaining('n’utilisez pas ailleurs'), findsOneWidget);
  });

  testWidgets('configures the password confirmation field', (tester) async {
    await _pumpRegister(tester);

    final field = _textField(tester, 'register-confirmation-field');
    expect(field.obscureText, isTrue);
    expect(field.textInputAction, TextInputAction.done);
  });

  testWidgets('shows and hides both password fields accessibly', (
    tester,
  ) async {
    await _pumpRegister(tester);

    await tester.tap(find.byTooltip('Afficher le mot de passe').first);
    await tester.pump();

    expect(_textField(tester, 'register-password-field').obscureText, isFalse);
    expect(
      _textField(tester, 'register-confirmation-field').obscureText,
      isTrue,
    );
    expect(find.byTooltip('Masquer le mot de passe'), findsOneWidget);
  });

  testWidgets('validates all required fields when empty', (tester) async {
    await _pumpRegister(tester);

    await _submit(tester);

    expect(find.text('Le nom complet est obligatoire.'), findsOneWidget);
    expect(find.text("L'adresse e-mail est obligatoire."), findsOneWidget);
    expect(find.text('Le mot de passe est obligatoire.'), findsOneWidget);
    expect(
      find.text('La confirmation du mot de passe est obligatoire.'),
      findsOneWidget,
    );
  });

  testWidgets('validates an invalid email address', (tester) async {
    await _pumpRegister(tester);
    await _enterValidRegistration(tester, email: 'adresse-invalide');

    await _submit(tester);

    expect(find.text('Adresse e-mail invalide.'), findsOneWidget);
  });

  testWidgets('validates a different password confirmation', (tester) async {
    await _pumpRegister(tester);
    await _enterValidRegistration(tester, confirmation: 'different');

    await _submit(tester);

    expect(
      find.text('Les mots de passe ne correspondent pas.'),
      findsOneWidget,
    );
  });

  testWidgets('requires explicit acceptance of terms', (tester) async {
    await _pumpRegister(tester);
    await _enterValidRegistration(tester, acceptTerms: false);

    await _submit(tester);

    expect(
      find.text('Vous devez accepter les conditions pour créer un compte.'),
      findsOneWidget,
    );
  });

  testWidgets('submits trimmed valid registration data', (tester) async {
    final repository = _TestAuthRepository();
    await _pumpRegister(
      tester,
      repository: repository,
      onRegistrationSuccess: () {},
    );
    await _enterValidRegistration(
      tester,
      name: '  Alex Martin  ',
      email: ' Alex@Example.com ',
    );

    await _submit(tester, settle: true);

    expect(repository.registerCalls, 1);
    expect(repository.lastName, 'Alex Martin');
    expect(repository.lastEmail, 'Alex@Example.com');
    expect(repository.lastPassword, 'password');
  });

  testWidgets('accepts a minimal non-empty password policy', (tester) async {
    final repository = _TestAuthRepository();
    await _pumpRegister(
      tester,
      repository: repository,
      onRegistrationSuccess: () {},
    );
    await _enterValidRegistration(tester, password: 'x', confirmation: 'x');

    await _submit(tester, settle: true);

    expect(repository.registerCalls, 1);
  });

  testWidgets('shows loading and preserves disabled form values', (
    tester,
  ) async {
    final repository = _TestAuthRepository(pending: Completer<UserSession>());
    await _pumpRegister(tester, repository: repository);
    await _enterValidRegistration(tester);

    await tester.ensureVisible(_submitButton);
    await tester.pump();
    await tester.tap(_submitButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    for (final key in _fieldKeys) {
      expect(_textField(tester, key).enabled, isFalse);
    }
    expect(
      tester
          .widget<AppCheckbox>(find.byKey(const Key('register-terms-checkbox')))
          .onChanged,
      isNull,
    );
    expect(
      _textField(tester, 'register-name-field').controller?.text,
      'Alex Martin',
    );
  });

  testWidgets('prevents double registration submission', (tester) async {
    final completer = Completer<UserSession>();
    final repository = _TestAuthRepository(pending: completer);
    await _pumpRegister(tester, repository: repository);
    await _enterValidRegistration(tester);

    await tester.ensureVisible(_submitButton);
    await tester.pump();
    await tester.tap(_submitButton);
    await tester.tap(_submitButton);
    await tester.pump();

    expect(repository.registerCalls, 1);
    completer.complete(_session);
    await tester.pumpAndSettle();
  });

  testWidgets('shows a typed email already used error', (tester) async {
    await _pumpRegister(
      tester,
      repository: MockAuthRepository(delay: Duration.zero),
    );
    await _enterValidRegistration(
      tester,
      email: MockAuthRepository.registeredEmail,
    );

    await _submit(tester, settle: true);

    expect(
      find.text('Un compte existe déjà avec cette adresse e-mail.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('register-submission-error')), findsOneWidget);
  });

  testWidgets('shows a safe generic registration error', (tester) async {
    await _pumpRegister(
      tester,
      repository: _TestAuthRepository(error: StateError('technical detail')),
    );
    await _enterValidRegistration(tester);

    await _submit(tester, settle: true);

    expect(
      find.text('Une erreur est survenue. Veuillez réessayer.'),
      findsOneWidget,
    );
    expect(find.textContaining('technical detail'), findsNothing);
  });

  testWidgets('reports mock success through the injected callback', (
    tester,
  ) async {
    var successCalls = 0;
    await _pumpRegister(
      tester,
      repository: MockAuthRepository(delay: Duration.zero),
      onRegistrationSuccess: () => successCalls++,
    );
    await _enterValidRegistration(tester);

    await _submit(tester, settle: true);

    expect(successCalls, 1);
  });

  testWidgets('navigates to the central home route after default success', (
    tester,
  ) async {
    await _pumpRegister(
      tester,
      repository: MockAuthRepository(delay: Duration.zero),
    );
    await _enterValidRegistration(tester);

    await _submit(tester, settle: true);

    expect(find.text('Destination principale'), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });

  testWidgets('exposes the login secondary action callback', (tester) async {
    var loginCalls = 0;
    await _pumpRegister(tester, onLogin: () => loginCalls++);

    await tester.ensureVisible(find.byKey(const Key('register-login-action')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('register-login-action')));
    await tester.pump();

    expect(loginCalls, 1);
  });

  testWidgets('navigates to the central login route by default', (
    tester,
  ) async {
    await _pumpRegister(tester);

    await tester.ensureVisible(find.byKey(const Key('register-login-action')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('register-login-action')));
    await tester.pumpAndSettle();

    expect(find.text('Destination connexion'), findsOneWidget);
  });

  testWidgets('exposes terms and privacy integration callbacks', (
    tester,
  ) async {
    var termsCalls = 0;
    var privacyCalls = 0;
    await _pumpRegister(
      tester,
      onTermsOfUse: () => termsCalls++,
      onPrivacyPolicy: () => privacyCalls++,
    );

    await tester.tap(find.byKey(const Key('register-terms-link')));
    await tester.tap(find.byKey(const Key('register-privacy-link')));
    await tester.pump();

    expect(termsCalls, 1);
    expect(privacyCalls, 1);
  });

  testWidgets('remains usable at 320 logical pixels', (tester) async {
    await _pumpRegister(tester, size: const Size(320, 700));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(_submitButton, findsOneWidget);
  });

  testWidgets('supports enlarged text without overflow', (tester) async {
    await _pumpRegister(
      tester,
      size: const Size(320, 700),
      textScaleFactor: 1.6,
    );

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();
    expect(_submitButton, findsOneWidget);
  });

  testWidgets('stays scrollable with a simulated mobile keyboard', (
    tester,
  ) async {
    await _pumpRegister(tester, size: const Size(320, 640), keyboardInset: 280);

    await tester.showKeyboard(_field('register-confirmation-field'));
    await tester.pump();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(_submitButton, findsOneWidget);
  });

  testWidgets('renders with the light theme', (tester) async {
    await _pumpRegister(tester, themeMode: ThemeMode.light);

    final context = tester.element(find.byType(RegisterScreen));
    expect(Theme.of(context).brightness, Brightness.light);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders with the dark theme', (tester) async {
    await _pumpRegister(tester, themeMode: ThemeMode.dark);

    final context = tester.element(find.byType(RegisterScreen));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes essential registration semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pumpRegister(tester);

    expect(find.bySemanticsLabel('Logo Social Flow AI'), findsOneWidget);
    expect(find.bySemanticsLabel('Créer mon compte'), findsWidgets);
    expect(find.byTooltip('Afficher le mot de passe'), findsNWidgets(2));
    expect(
      find.bySemanticsLabel(
        RegExp('J’accepte les conditions et la confidentialité'),
      ),
      findsWidgets,
    );

    semantics.dispose();
  });

  testWidgets('keeps social registration placeholders disabled', (
    tester,
  ) async {
    await _pumpRegister(tester);

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
  userId: 'registered-user',
  name: 'Alex Martin',
  email: 'alex@example.com',
  accessToken: 'test-session',
);

const _fieldKeys = [
  'register-name-field',
  'register-email-field',
  'register-password-field',
  'register-confirmation-field',
];

final _submitButton = find.byKey(const Key('register-submit'));

Finder _field(String key) =>
    find.descendant(of: find.byKey(Key(key)), matching: find.byType(TextField));

TextField _textField(WidgetTester tester, String key) =>
    tester.widget<TextField>(_field(key));

Future<void> _enterValidRegistration(
  WidgetTester tester, {
  String name = 'Alex Martin',
  String email = 'alex@example.com',
  String password = 'password',
  String confirmation = 'password',
  bool acceptTerms = true,
}) async {
  await tester.enterText(_field('register-name-field'), name);
  await tester.enterText(_field('register-email-field'), email);
  await tester.enterText(_field('register-password-field'), password);
  await tester.enterText(_field('register-confirmation-field'), confirmation);
  if (acceptTerms) {
    await tester.tap(find.byKey(const Key('register-terms-checkbox')));
    await tester.pump();
  }
}

Future<void> _submit(WidgetTester tester, {bool settle = false}) async {
  await tester.ensureVisible(_submitButton);
  await tester.pump();
  await tester.tap(_submitButton);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

Future<void> _pumpRegister(
  WidgetTester tester, {
  AuthRepository? repository,
  ThemeMode themeMode = ThemeMode.light,
  Size size = const Size(390, 844),
  double textScaleFactor = 1,
  double keyboardInset = 0,
  VoidCallback? onLogin,
  VoidCallback? onPrivacyPolicy,
  VoidCallback? onRegistrationSuccess,
  VoidCallback? onTermsOfUse,
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
          AppRoutes.login:
              (_) => const Scaffold(body: Text('Destination connexion')),
        },
        home: RegisterScreen(
          onLogin: onLogin,
          onPrivacyPolicy: onPrivacyPolicy,
          onRegistrationSuccess: onRegistrationSuccess,
          onTermsOfUse: onTermsOfUse,
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
  int registerCalls = 0;
  String? lastName;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<UserSession?> currentSession() async => null;

  @override
  Future<UserSession> login({
    required String email,
    required String password,
  }) async => _session;

  @override
  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    lastName = name;
    lastEmail = email;
    lastPassword = password;
    if (error case final error?) throw error;
    if (pending case final pending?) return pending.future;
    return _session;
  }

  @override
  Future<void> logout() async {}
}
