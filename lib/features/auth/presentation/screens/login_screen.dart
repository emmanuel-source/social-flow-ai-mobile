import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_fields.dart';
import '../../domain/entities/auth_failure.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_screen_components.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    this.onCreateAccount,
    this.onForgotPassword,
    this.onLoginSuccess,
    super.key,
  });

  final VoidCallback? onCreateAccount;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onLoginSuccess;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _submissionError;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_submitting) return;

    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.required(
      _passwordController.text,
      label: 'Le mot de passe',
    );
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _submissionError = null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => _submitting = true);
    final success = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;

    setState(() => _submitting = false);
    if (success) {
      final onLoginSuccess = widget.onLoginSuccess;
      if (onLoginSuccess != null) {
        onLoginSuccess();
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (_) => false,
        );
      }
      return;
    }

    final error = ref.read(authControllerProvider).error;
    setState(() {
      _submissionError =
          error is AuthFailure
              ? error.message
              : const AuthFailure.generic().message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = _submitting || auth.isLoading;

    return AuthScreenLayout(
      builder:
          (context, compact) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Bon retour !',
                subtitle:
                    'Connectez-vous à Social Flow AI pour reprendre votre workflow.',
              ),
              SizedBox(height: compact ? AppSpacing.xl : AppSpacing.xxxl),
              AppCard(
                elevated: true,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        key: const Key('login-email-field'),
                        label: 'E-mail',
                        hint: 'vous@entreprise.com',
                        controller: _emailController,
                        errorText: _emailError,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        prefixIcon: const Icon(Icons.mail_outline),
                        onChanged: (_) => _clearErrors(email: true),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppPasswordField(
                        key: const Key('login-password-field'),
                        label: 'Mot de passe',
                        controller: _passwordController,
                        errorText: _passwordError,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => _clearErrors(password: true),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppTertiaryButton(
                          key: const Key('login-forgot-password'),
                          label: 'Mot de passe oublié ?',
                          onPressed:
                              isLoading
                                  ? null
                                  : widget.onForgotPassword ??
                                      () => showAuthFeatureUnavailable(
                                        context,
                                        'La récupération du mot de passe',
                                      ),
                        ),
                      ),
                      if (_submissionError != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        AuthErrorBanner(
                          key: const Key('login-submission-error'),
                          message: _submissionError!,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ] else
                        const SizedBox(height: AppSpacing.sm),
                      AppPrimaryButton(
                        key: const Key('login-submit'),
                        label: 'Se connecter',
                        icon: Icons.arrow_forward,
                        loading: isLoading,
                        onPressed: isLoading ? null : _login,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthSecondaryAction(
                prompt: 'Pas encore de compte ?',
                actionLabel: 'Créer un compte',
                actionKey: const Key('login-create-account'),
                onPressed:
                    isLoading
                        ? null
                        : widget.onCreateAccount ??
                            () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
                            ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AuthSocialPlaceholders(),
            ],
          ),
    );
  }

  void _clearErrors({bool email = false, bool password = false}) {
    if ((email && _emailError != null) ||
        (password && _passwordError != null) ||
        _submissionError != null) {
      setState(() {
        if (email) _emailError = null;
        if (password) _passwordError = null;
        _submissionError = null;
      });
    }
  }
}
