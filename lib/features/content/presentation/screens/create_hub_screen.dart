import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/action_tile.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_list_tile.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/section_header.dart';

class CreateHubScreen extends StatelessWidget {
  const CreateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('create-hub-scroll'),
          padding: AppSpacing.screenInsets,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.contentMaxWidth,
                ),
                child: Semantics(
                  key: const Key('create-hub-semantics'),
                  container: true,
                  explicitChildNodes: true,
                  label: 'Centre de création Social Flow AI',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Créer',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Que souhaitez-vous créer ?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _PrimaryCreationCard(
                        onPressed: () => _open(context, AppRoutes.postType),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _AiCreationSection(
                        onCreateWithAi:
                            () => _open(context, AppRoutes.aiAssistant),
                        onGenerateIdeas:
                            () => _open(context, AppRoutes.aiAssistant),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _AlternativeCreationGrid(
                        onImportMedia:
                            () => _open(context, AppRoutes.mediaLibrary),
                        onTransformVideo:
                            () => _open(context, AppRoutes.videoSource),
                        onCampaign: () => _open(context, AppRoutes.campaign),
                        onMediaLibrary:
                            () => _open(context, AppRoutes.mediaLibrary),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _ResumeSection(
                        onDrafts: () => _open(context, AppRoutes.drafts),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}

class _PrimaryCreationCard extends StatelessWidget {
  const _PrimaryCreationCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const Key('primary-create-action'),
      container: true,
      explicitChildNodes: true,
      label: 'Nouvelle publication, action principale',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.brand,
          borderRadius: AppRadius.modal,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.control,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.add_box_outlined,
                        color: AppColors.brandPrimary,
                        size: AppSizes.iconLarge,
                      ),
                    ),
                  ),
                  AppBadge(label: 'Action principale', tone: AppBadgeTone.info),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Nouvelle publication',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Créez une publication image, vidéo, carrousel ou texte pour vos réseaux.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                key: const Key('new-publication-button'),
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.brandPrimary,
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Commencer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiCreationSection extends StatelessWidget {
  const _AiCreationSection({
    required this.onCreateWithAi,
    required this.onGenerateIdeas,
  });

  final VoidCallback onCreateWithAi;
  final VoidCallback onGenerateIdeas;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Créer avec l’IA',
          subtitle: 'Accélérez votre réflexion sans perdre le contrôle',
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              Semantics(
                button: true,
                label:
                    'Assistant IA. Construire un contenu guidé étape par étape',
                child: ExcludeSemantics(
                  child: AppListTile(
                    title: 'Assistant IA',
                    subtitle: 'Construire un contenu guidé étape par étape',
                    leading: _ActionIcon(
                      icon: Icons.auto_awesome,
                      color: scheme.primary,
                      background: scheme.primaryContainer,
                    ),
                    trailing: const AppBadge(
                      label: 'IA',
                      tone: AppBadgeTone.info,
                    ),
                    onTap: onCreateWithAi,
                  ),
                ),
              ),
              const Divider(height: 1),
              Semantics(
                button: true,
                label:
                    'Générer des idées. Trouver des angles adaptés à vos objectifs',
                child: ExcludeSemantics(
                  child: AppListTile(
                    title: 'Générer des idées',
                    subtitle: 'Trouver des angles adaptés à vos objectifs',
                    leading: _ActionIcon(
                      icon: Icons.lightbulb_outline,
                      color: scheme.secondary,
                      background: scheme.secondaryContainer,
                    ),
                    onTap: onGenerateIdeas,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlternativeCreationGrid extends StatelessWidget {
  const _AlternativeCreationGrid({
    required this.onImportMedia,
    required this.onTransformVideo,
    required this.onCampaign,
    required this.onMediaLibrary,
  });

  final VoidCallback onImportMedia;
  final VoidCallback onTransformVideo;
  final VoidCallback onCampaign;
  final VoidCallback onMediaLibrary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Créer autrement',
          subtitle: 'Démarrez depuis un média, une vidéo ou un objectif',
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = AppBreakpoints.isCompact(constraints.maxWidth);
            final scaled = MediaQuery.textScalerOf(context).scale(1) > 1.1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              mainAxisExtent:
                  scaled
                      ? 172
                      : compact
                      ? 140
                      : 124,
              children: [
                ActionTile(
                  icon: Icons.upload_file_outlined,
                  title: 'Importer un média',
                  subtitle: 'Ajouter une image ou une vidéo',
                  onTap: onImportMedia,
                ),
                ActionTile(
                  icon: Icons.content_cut,
                  title: 'Transformer une vidéo',
                  subtitle: 'Préparer des clips courts',
                  onTap: onTransformVideo,
                ),
                ActionTile(
                  icon: Icons.campaign_outlined,
                  title: 'Créer une campagne',
                  subtitle: 'Partir d’un objectif marketing',
                  onTap: onCampaign,
                ),
                ActionTile(
                  icon: Icons.perm_media_outlined,
                  title: 'Bibliothèque média',
                  subtitle: 'Retrouver vos ressources',
                  onTap: onMediaLibrary,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ResumeSection extends StatelessWidget {
  const _ResumeSection({required this.onDrafts});

  final VoidCallback onDrafts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Reprendre',
          subtitle: 'Continuez un contenu déjà commencé',
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          onTap: onDrafts,
          semanticLabel: 'Ouvrir les brouillons',
          child: Row(
            children: [
              _ActionIcon(
                icon: Icons.edit_note_outlined,
                color: scheme.primary,
                background: scheme.primaryContainer,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brouillons',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Reprendre une création enregistrée',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.control,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, color: color, size: AppSizes.iconMedium),
      ),
    );
  }
}
