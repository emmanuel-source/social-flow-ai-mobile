import 'package:flutter/material.dart';

import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/social_platform.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_list_tile.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/profile_overview.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    required this.overview,
    required this.onWorkspace,
    required this.onSocialAccounts,
    required this.onBrandKit,
    required this.onTeam,
    required this.onApprovals,
    required this.onAgents,
    required this.onSubscription,
    required this.onNotifications,
    required this.onSecurity,
    required this.onSettings,
    required this.onLogout,
    super.key,
  });

  final ProfileOverview overview;
  final VoidCallback onWorkspace;
  final VoidCallback onSocialAccounts;
  final VoidCallback onBrandKit;
  final VoidCallback onTeam;
  final VoidCallback onApprovals;
  final VoidCallback onAgents;
  final VoidCallback onSubscription;
  final VoidCallback onNotifications;
  final VoidCallback onSecurity;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('profile-scroll'),
      padding: AppSpacing.screenInsets,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PageHeader(isDemo: overview.isDemo),
              const SizedBox(height: AppSpacing.xxl),
              _IdentityCard(identity: overview.identity),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(
                title: 'Workspace actif',
                subtitle: 'Votre contexte de travail actuel',
              ),
              const SizedBox(height: AppSpacing.md),
              _WorkspaceCard(workspace: overview.workspace, onTap: onWorkspace),
              const SizedBox(height: AppSpacing.sectionGap),
              SectionHeader(
                title: 'Comptes sociaux',
                subtitle:
                    '${overview.connectedAccountsCount} sur ${overview.socialAccounts.length} connectés',
                actionLabel: 'Gérer',
                onAction: onSocialAccounts,
              ),
              const SizedBox(height: AppSpacing.md),
              _SocialAccountsCard(accounts: overview.socialAccounts),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(
                title: 'Organisation',
                subtitle: 'Marque, équipe et automatisations',
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.palette_outlined,
                      title: 'Brand Kit',
                      subtitle: 'Identité et règles de marque',
                      onTap: onBrandKit,
                    ),
                    _ProfileTile(
                      icon: Icons.groups_outlined,
                      title: 'Équipe et permissions',
                      subtitle: '${overview.workspace.membersCount} membres',
                      onTap: onTeam,
                    ),
                    _ProfileTile(
                      icon: Icons.fact_check_outlined,
                      title: 'Validations',
                      subtitle: 'Flux de revue des contenus',
                      onTap: onApprovals,
                    ),
                    _ProfileTile(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Agents et automatisations',
                      subtitle: 'Assistants et tâches planifiées',
                      onTap: onAgents,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(
                title: 'Compte et préférences',
                subtitle: 'Forfait, alertes et sécurité',
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Abonnement',
                      subtitle: 'Plan ${overview.identity.planName}',
                      onTap: onSubscription,
                    ),
                    _ProfileTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: 'Canaux et fréquence des alertes',
                      onTap: onNotifications,
                    ),
                    _ProfileTile(
                      icon: Icons.security_outlined,
                      title: 'Sécurité',
                      subtitle: 'Accès et sessions actives',
                      onTap: onSecurity,
                    ),
                    _ProfileTile(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      subtitle: 'Langue, thème et préférences',
                      onTap: onSettings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppSecondaryButton(
                key: const Key('profile-logout'),
                label: 'Se déconnecter',
                icon: Icons.logout,
                onPressed: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.isDemo});

  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Votre centre de contrôle personnel et organisationnel.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isDemo) ...[
            const SizedBox(width: AppSpacing.sm),
            const AppBadge(label: 'Données démo', tone: AppBadgeTone.info),
          ],
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.identity});

  final ProfileIdentity identity;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: true,
      semanticLabel: 'Profil de ${identity.name}, ${identity.email}',
      child: Row(
        children: [
          AppAvatar(label: identity.name, size: AppAvatarSize.large),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  identity.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  identity.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppBadge(
                      label: 'Plan ${identity.planName}',
                      icon: Icons.workspace_premium_outlined,
                      tone: AppBadgeTone.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({required this.workspace, required this.onTap});

  final ProfileWorkspaceSummary workspace;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      semanticLabel:
          'Workspace ${workspace.name}, rôle ${workspace.role}, ${workspace.membersCount} membres',
      child: Row(
        children: [
          const AppAvatar(
            label: 'Social Flow AI',
            icon: Icons.workspaces_outline,
            size: AppAvatarSize.large,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workspace.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${workspace.role} · ${workspace.membersCount} membres',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _SocialAccountsCard extends StatelessWidget {
  const _SocialAccountsCard({required this.accounts});

  final List<ProfileSocialAccount> accounts;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final account in accounts)
            AppBadge(
              label:
                  '${account.platform.label} · ${account.isConnected ? 'Connecté' : 'Non connecté'}',
              icon: _platformIcon(account.platform),
              tone:
                  account.isConnected
                      ? AppBadgeTone.success
                      : AppBadgeTone.neutral,
            ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

IconData _platformIcon(SocialPlatform platform) => switch (platform) {
  SocialPlatform.instagram => Icons.camera_alt_outlined,
  SocialPlatform.facebook => Icons.facebook,
  SocialPlatform.tiktok => Icons.music_note_outlined,
  SocialPlatform.youtube => Icons.play_circle_outline,
  _ => Icons.public,
};
