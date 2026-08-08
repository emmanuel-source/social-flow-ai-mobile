import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_selection_controls.dart';
import '../../../../shared/widgets/app_text_fields.dart';
import '../../domain/entities/auth_failure.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_screen_components.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    this.onLogin,
    this.onPrivacyPolicy,
    this.onRegistrationSuccess,
    this.onTermsOfUse,
    super.key,
  });

  final VoidCallback? onLogin;
  final VoidCallback? onPrivacyPolicy;
  final VoidCallback? onRegistrationSuccess;
  final VoidCallback? onTermsOfUse;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmationError;
  String? _termsError;
  String? _submissionError;
  bool _acceptedTerms = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_submitting) return;

    final nameError = Validators.required(
      _nameController.text,
      label: 'Le nom complet',
    );
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.required(
      _passwordController.text,
      label: 'Le mot de passe',
    );
    var confirmationError = Validators.required(
      _confirmationController.text,
      label: 'La confirmation du mot de passe',
    );
    if (confirmationError == null &&
        _confirmationController.text != _passwordController.text) {
      confirmationError = 'Les mots de passe ne correspondent pas.';
    }
    final termsError =
        _acceptedTerms
            ? null
            : 'Vous devez accepter les conditions pour créer un compte.';

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmationError = confirmationError;
      _termsError = termsError;
      _submissionError = null;
    });
    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmationError != null ||
        termsError != null) {
      return;
    }

    setState(() => _submitting = true);
    final success = await ref
        .read(authControllerProvider.notifier)
        .register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;

    setState(() => _submitting = false);
    if (success) {
      final onRegistrationSuccess = widget.onRegistrationSuccess;
      if (onRegistrationSuccess != null) {
        onRegistrationSuccess();
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
                title: 'Créez votre compte',
                subtitle:
                    'Rejoignez Social Flow AI et centralisez votre workflow social.',
              ),
              SizedBox(height: compact ? AppSpacing.xl : AppSpacing.xxxl),
              AppCard(
                elevated: true,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        key: const Key('register-name-field'),
                        label: 'Nom complet',
                        hint: 'Votre nom',
                        controller: _nameController,
                        errorText: _nameError,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        prefixIcon: const Icon(Icons.person_outline),
                        onChanged: (_) => _clearErrors(name: true),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        key: const Key('register-email-field'),
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
                        key: const Key('register-password-field'),
                        label: 'Mot de passe',
                        controller: _passwordController,
                        errorText: _passwordError,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _clearErrors(password: true),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Choisissez un mot de passe que vous n’utilisez pas ailleurs.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppPasswordField(
                        key: const Key('register-confirmation-field'),
                        label: 'Confirmer le mot de passe',
                        controller: _confirmationController,
                        errorText: _confirmationError,
                        enabled: !isLoading,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => _clearErrors(confirmation: true),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCheckbox(
                        key: const Key('register-terms-checkbox'),
                        label: 'J’accepte les conditions et la confidentialité',
                        value: _acceptedTerms,
                        onChanged:
                            isLoading
                                ? null
                                : (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                    _termsError = null;
                                    _submissionError = null;
                                  });
                                },
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          AppTertiaryButton(
                            key: const Key('register-terms-link'),
                            label: 'Conditions d’utilisation',
                            onPressed:
                                isLoading
                                    ? null
                                    : widget.onTermsOfUse ??
                                        () => showAuthFeatureUnavailable(
                                          context,
                                          'Les conditions d’utilisation',
                                        ),
                          ),
                          AppTertiaryButton(
                            key: const Key('register-privacy-link'),
                            label: 'Politique de confidentialité',
                            onPressed:
                                isLoading
                                    ? null
                                    : widget.onPrivacyPolicy ??
                                        () => showAuthFeatureUnavailable(
                                          context,
                                          'La politique de confidentialité',
                                        ),
                          ),
                        ],
                      ),
                      if (_termsError != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        _TermsError(message: _termsError!),
                      ],
                      if (_submissionError != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AuthErrorBanner(
                          key: const Key('register-submission-error'),
                          message: _submissionError!,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      AppPrimaryButton(
                        key: const Key('register-submit'),
                        label: 'Créer mon compte',
                        icon: Icons.arrow_forward,
                        loading: isLoading,
                        onPressed: isLoading ? null : _register,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthSecondaryAction(
                prompt: 'Déjà un compte ?',
                actionLabel: 'Se connecter',
                actionKey: const Key('register-login-action'),
                onPressed:
                    isLoading
                        ? null
                        : widget.onLogin ??
                            () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AuthSocialPlaceholders(),
            ],
          ),
    );
  }

  void _clearErrors({
    bool name = false,
    bool email = false,
    bool password = false,
    bool confirmation = false,
  }) {
    if ((name && _nameError != null) ||
        (email && _emailError != null) ||
        (password && _passwordError != null) ||
        (confirmation && _confirmationError != null) ||
        _submissionError != null) {
      setState(() {
        if (name) _nameError = null;
        if (email) _emailError = null;
        if (password) _passwordError = null;
        if (confirmation) _confirmationError = null;
        _submissionError = null;
      });
    }
  }
}

class _TermsError extends StatelessWidget {
  const _TermsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label: message,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
      ),
    );
  }
}
