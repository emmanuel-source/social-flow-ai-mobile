import 'package:flutter/material.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_buttons.dart';

typedef AuthScreenBuilder = Widget Function(BuildContext context, bool compact);

class AuthScreenLayout extends StatelessWidget {
  const AuthScreenLayout({required this.builder, super.key});

  final AuthScreenBuilder builder;

  @override
  Widget build(BuildContext context) {
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
                    child: builder(context, compact),
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

class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

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
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Erreur d’authentification. $message',
      child: Container(
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

class AuthSecondaryAction extends StatelessWidget {
  const AuthSecondaryAction({
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
    this.actionKey,
    super.key,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback? onPressed;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$prompt $actionLabel',
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(prompt, style: Theme.of(context).textTheme.bodyMedium),
          AppTertiaryButton(
            key: actionKey,
            label: actionLabel,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class AuthSocialPlaceholders extends StatelessWidget {
  const AuthSocialPlaceholders({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
        const SizedBox(height: AppSpacing.md),
        Text(
          'Les connexions sociales seront activées prochainement.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

void showAuthFeatureUnavailable(BuildContext context, String feature) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text('$feature sera bientôt disponible.')));
}
