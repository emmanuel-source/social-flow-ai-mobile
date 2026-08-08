import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_buttons.dart';

typedef OnboardingCompleted = Future<void> Function();

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({this.onCompleted, super.key});

  static const stepCount = 4;

  final OnboardingCompleted? onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _isCompleting = false;

  static const _steps = <_OnboardingStep>[
    _OnboardingStep(
      icon: Icons.hub_outlined,
      title: 'Tous vos réseaux, un seul espace',
      description:
          'Pilotez vos comptes et vos contenus depuis une vue claire et centralisée.',
      visualLabel: 'Réseaux sociaux réunis dans un espace unique',
    ),
    _OnboardingStep(
      icon: Icons.auto_awesome,
      title: 'Créez plus vite avec l’IA',
      description:
          'Trouvez des idées, rédigez et adaptez chaque contenu à sa plateforme.',
      visualLabel: 'Assistant IA pour créer et adapter du contenu',
    ),
    _OnboardingStep(
      icon: Icons.calendar_month_outlined,
      title: 'Planifiez sans friction',
      description:
          'Programmez vos publications au bon moment et gardez une vision nette du calendrier.',
      visualLabel: 'Calendrier de programmation des publications',
    ),
    _OnboardingStep(
      icon: Icons.insights_outlined,
      title: 'Mesurez ce qui fonctionne',
      description:
          'Suivez vos performances et concentrez vos efforts sur les contenus qui comptent.',
      visualLabel: 'Analyse des performances des contenus',
    ),
  ];

  bool get _isLastStep => _index == _steps.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_isLastStep) {
      await _finish();
      return;
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(_index + 1);
      return;
    }

    await _controller.nextPage(
      duration: AppMotion.standard,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);

    final onCompleted = widget.onCompleted;
    if (onCompleted != null) {
      await onCompleted();
    } else {
      await LocalStorage.setOnboardingCompleted(true);
    }

    if (!mounted) return;
    if (onCompleted == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    setState(() => _isCompleting = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = AppBreakpoints.isCompact(constraints.maxWidth);
            final horizontalPadding = compact ? AppSpacing.md : AppSpacing.xxl;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.sm,
                horizontalPadding,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  _OnboardingHeader(
                    showSkip: !_isLastStep,
                    onSkip: _isCompleting ? null : _finish,
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemCount: _steps.length,
                      itemBuilder:
                          (context, index) => _OnboardingPage(
                            step: _steps[index],
                            compact: compact,
                          ),
                    ),
                  ),
                  _OnboardingProgress(
                    currentStep: _index,
                    stepCount: _steps.length,
                    activeColor: colorScheme.primary,
                    inactiveColor: colorScheme.outlineVariant,
                    animationDuration:
                        reduceMotion ? Duration.zero : AppMotion.fast,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPrimaryButton(
                    key: const Key('onboarding-primary-action'),
                    label: _isLastStep ? 'Se connecter' : 'Suivant',
                    icon:
                        _isLastStep
                            ? Icons.arrow_forward
                            : Icons.arrow_forward_ios,
                    loading: _isCompleting,
                    onPressed: _isCompleting ? null : _next,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.showSkip, required this.onSkip});

  final bool showSkip;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            label: 'Social Flow AI',
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.brandPrimary,
                  size: AppSizes.iconLarge,
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    'Social Flow AI',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showSkip)
          AppTertiaryButton(label: 'Passer', onPressed: onSkip)
        else
          const SizedBox.square(dimension: AppSizes.minimumTouchTarget),
      ],
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.step, required this.compact});

  final _OnboardingStep step;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _OnboardingVisual(step: step, compact: compact),
                  SizedBox(height: compact ? AppSpacing.xl : AppSpacing.xxxl),
                  Semantics(
                    header: true,
                    child: Text(
                      step.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.contentMaxWidth,
                    ),
                    child: Text(
                      step.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({required this.step, required this.compact});

  final _OnboardingStep step;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final visualSize = AppSpacing.giant * (compact ? 3 : 4);

    return Semantics(
      image: true,
      label: step.visualLabel,
      child: ExcludeSemantics(
        child: Container(
          width: visualSize,
          height: visualSize,
          decoration: BoxDecoration(
            gradient: AppGradients.ai,
            borderRadius: AppRadius.modal,
            boxShadow: AppShadows.elevated(brightness),
          ),
          alignment: Alignment.center,
          child: Icon(
            step.icon,
            size: AppSizes.iconHero + AppSizes.iconLarge,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _OnboardingProgress extends StatelessWidget {
  const _OnboardingProgress({
    required this.currentStep,
    required this.stepCount,
    required this.activeColor,
    required this.inactiveColor,
    required this.animationDuration,
  });

  final int currentStep;
  final int stepCount;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final label = 'Étape ${currentStep + 1} sur $stepCount';
    return Semantics(
      container: true,
      label: label,
      value: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              stepCount,
              (index) => AnimatedContainer(
                key: Key('onboarding-progress-$index'),
                duration: animationDuration,
                width: index == currentStep ? AppSpacing.xxl : AppSpacing.sm,
                height: AppSpacing.sm,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: index == currentStep ? activeColor : inactiveColor,
                  borderRadius: AppRadius.capsule,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.visualLabel,
  });

  final IconData icon;
  final String title;
  final String description;
  final String visualLabel;
}
