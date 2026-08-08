import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_fields.dart';
import '../../domain/entities/auth_failure.dart';
import '../controllers/auth_controller.dart';

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

    if (success) {
      setState(() => _submitting = false);
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
      _submitting = false;
      _submissionError =
          error is AuthFailure
              ? error.message
              : const AuthFailure.generic().message;
    });
  }

  void _showUnavailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature sera bientôt disponible.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = _submitting || auth.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = AppBreakpoints.isCompact(constraints.maxWidth);
            final horizontalPadding = compact ? AppSpacing.md : AppSpacing.xxl;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.lg,
                horizontalPadding,
                AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppSpacing.huge,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.contentMaxWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _LoginHeader(),
                        SizedBox(
                          height: compact ? AppSpacing.xl : AppSpacing.xxxl,
                        ),
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
                                  onChanged: (_) {
                                    if (_emailError != null ||
                                        _submissionError != null) {
                                      setState(() {
                                        _emailError = null;
                                        _submissionError = null;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AppPasswordField(
                                  key: const Key('login-password-field'),
                                  label: 'Mot de passe',
                                  controller: _passwordController,
                                  errorText: _passwordError,
                                  enabled: !isLoading,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (_) {
                                    if (_passwordError != null ||
                                        _submissionError != null) {
                                      setState(() {
                                        _passwordError = null;
                                        _submissionError = null;
                                      });
                                    }
                                  },
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
                                                () => _showUnavailable(
                                                  'La récupération du mot de passe',
                                                ),
                                  ),
                                ),
                                if (_submissionError != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  _LoginError(message: _submissionError!),
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
                        _CreateAccountAction(
                          enabled: !isLoading,
                          onPressed:
                              widget.onCreateAccount ??
                              () => _showUnavailable('La création de compte'),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const _SocialLoginPlaceholders(),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Les connexions sociales seront activées prochainement.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Semantics(
          image: true,
          label: 'Logo Social Flow AI',
          child: ExcludeSemantics(
            child: Container(
              width: AppSizes.iconHero + AppSpacing.xxl,
              height: AppSizes.iconHero + AppSpacing.xxl,
              decoration: const BoxDecoration(
                gradient: AppGradients.ai,
                borderRadius: AppRadius.modal,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: AppSizes.iconHero,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Semantics(
          header: true,
          child: Text(
            'Bon retour !',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Connectez-vous à Social Flow AI pour reprendre votre workflow.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LoginError extends StatelessWidget {
  const _LoginError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Erreur de connexion. $message',
      child: Container(
        key: const Key('login-submission-error'),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: AppRadius.control,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateAccountAction extends StatelessWidget {
  const _CreateAccountAction({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Pas encore de compte ? Créer un compte',
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Pas encore de compte ?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          AppTertiaryButton(
            key: const Key('login-create-account'),
            label: 'Créer un compte',
            onPressed: enabled ? onPressed : null,
          ),
        ],
      ),
    );
  }
}

class _SocialLoginPlaceholders extends StatelessWidget {
  const _SocialLoginPlaceholders();

  @override
  Widget build(BuildContext context) {
    final usesLargeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    const buttons = <Widget>[
      AppSecondaryButton(
        label: 'Google',
        icon: Icons.g_mobiledata,
        onPressed: null,
        expand: false,
      ),
      AppSecondaryButton(
        label: 'Facebook',
        icon: Icons.facebook,
        onPressed: null,
        expand: false,
      ),
      AppSecondaryButton(
        label: 'Apple',
        icon: Icons.apple,
        onPressed: null,
        expand: false,
      ),
    ];

    return Column(
      children: [
        if (usesLargeText)
          Text(
            'Ou continuer avec',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          )
        else
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'Ou continuer avec',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        if (usesLargeText)
          const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.sm,
            children: buttons,
          )
        else
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: buttons,
          ),
      ],
    );
  }
}
