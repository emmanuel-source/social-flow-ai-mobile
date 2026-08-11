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
import '../models/demo_social_account.dart';

class PlatformsScreen extends ConsumerWidget {
  const PlatformsScreen({this.onContinue, this.onConnect, super.key});

  final ValueChanged<SocialPost>? onContinue;
  final ValueChanged<SocialPlatform>? onConnect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(composerControllerProvider);
    final available = {
      for (final account in demoSocialAccounts)
        if (account.connected) account.platform,
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
          for (var index = 0; index < demoSocialAccounts.length; index++) ...[
            _buildAccountCard(
              context,
              ref,
              demoSocialAccounts[index],
              selected.contains(demoSocialAccounts[index].platform),
            ),
            if (index < demoSocialAccounts.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xl),
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
    DemoSocialAccount account,
    bool selected,
  ) {
    return SocialNetworkCard(
      key: Key('platform-${account.platform.name}'),
      platform: account.platform,
      accountLabel: account.accountLabel,
      connected: account.connected,
      selected: selected,
      compact: true,
      onTap:
          account.connected
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
