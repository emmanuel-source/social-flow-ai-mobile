import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/social_network_card.dart';
import '../../domain/entities/social_post.dart';
import '../controllers/composer_controller.dart';

class PlatformsScreen extends ConsumerWidget {
  const PlatformsScreen({this.onContinue, this.onConnect, super.key});

  final ValueChanged<SocialPost>? onContinue;
  final ValueChanged<SocialPlatform>? onConnect;

  static const _demoAccounts = <_DemoSocialAccount>[
    _DemoSocialAccount(
      platform: SocialPlatform.instagram,
      accountLabel: '@socialflow',
      connected: true,
    ),
    _DemoSocialAccount(
      platform: SocialPlatform.facebook,
      accountLabel: 'Social Flow AI',
      connected: true,
    ),
    _DemoSocialAccount(
      platform: SocialPlatform.tiktok,
      accountLabel: '@socialflow',
      connected: true,
    ),
    _DemoSocialAccount(
      platform: SocialPlatform.youtube,
      accountLabel: 'Social Flow AI',
      connected: true,
    ),
    _DemoSocialAccount(
      platform: SocialPlatform.linkedin,
      accountLabel: 'Social Flow AI',
      connected: true,
    ),
    _DemoSocialAccount(platform: SocialPlatform.x),
    _DemoSocialAccount(platform: SocialPlatform.threads),
    _DemoSocialAccount(platform: SocialPlatform.pinterest),
    _DemoSocialAccount(platform: SocialPlatform.snapchat),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(composerControllerProvider);
    final available = {
      for (final account in _demoAccounts)
        if (account.connected && account.compatible) account.platform,
    };
    final selected = post.platforms.intersection(available);
    final allSelected =
        available.isNotEmpty && selected.length == available.length;

    return FeatureScaffold(
      title: 'Choisissez vos réseaux',
      subtitle: 'Étape 3 · Diffusion',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Où souhaitez-vous publier ?',
            subtitle:
                'Sélectionnez les comptes qui recevront ce contenu source.',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppBadge(
                label:
                    '${selected.length} réseau${selected.length > 1 ? 'x' : ''} sélectionné${selected.length > 1 ? 's' : ''}',
                icon: Icons.check_circle_outline,
                tone:
                    selected.isEmpty ? AppBadgeTone.neutral : AppBadgeTone.info,
                semanticLabel:
                    '${selected.length} plateformes sélectionnées sur ${available.length} disponibles',
              ),
              const AppBadge(
                label: 'Données de démonstration',
                icon: Icons.science_outlined,
                tone: AppBadgeTone.warning,
              ),
              AppTertiaryButton(
                label:
                    allSelected ? 'Tout désélectionner' : 'Tout sélectionner',
                onPressed:
                    () => ref
                        .read(composerControllerProvider.notifier)
                        .setPlatforms(allSelected ? {} : available),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Compatibilité préliminaire : aucune restriction par plateforme n’est appliquée à ce stade.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0; index < _demoAccounts.length; index++) ...[
            _buildAccountCard(
              context,
              ref,
              _demoAccounts[index],
              selected.contains(_demoAccounts[index].platform),
            ),
            if (index < _demoAccounts.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppPrimaryButton(
            key: const Key('platforms-continue'),
            label: 'Continuer',
            icon: Icons.arrow_forward,
            onPressed:
                selected.isEmpty
                    ? null
                    : () => _continue(context, ref, selected),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            selected.isEmpty
                ? 'Sélectionnez au moins un compte connecté pour continuer.'
                : 'Votre contenu source restera inchangé à cette étape.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    WidgetRef ref,
    _DemoSocialAccount account,
    bool selected,
  ) {
    return SocialNetworkCard(
      key: Key('platform-${account.platform.name}'),
      platform: account.platform,
      accountLabel:
          account.connected ? account.accountLabel : 'Aucun compte connecté',
      connected: account.connected,
      compatible: account.compatible,
      selected: selected,
      compact: true,
      onTap:
          account.connected && account.compatible
              ? () => ref
                  .read(composerControllerProvider.notifier)
                  .togglePlatform(account.platform)
              : () => _connect(context, account.platform),
    );
  }

  void _connect(BuildContext context, SocialPlatform platform) {
    final callback = onConnect;
    if (callback != null) {
      callback(platform);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.accounts);
  }

  void _continue(
    BuildContext context,
    WidgetRef ref,
    Set<SocialPlatform> selected,
  ) {
    ref.read(composerControllerProvider.notifier).setPlatforms(selected);
    final post = ref.read(composerControllerProvider);
    final callback = onContinue;
    if (callback != null) {
      callback(post);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.postAdapt);
  }
}

class _DemoSocialAccount {
  const _DemoSocialAccount({
    required this.platform,
    this.accountLabel,
    this.connected = false,
  });

  final SocialPlatform platform;
  final String? accountLabel;
  final bool connected;
  final bool compatible = true;
}
