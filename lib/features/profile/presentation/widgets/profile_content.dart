import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_list_tile.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/social_platform_visuals.dart';
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
              const SizedBox(height: AppSpacing.lg),
              _IdentityCard(identity: overview.identity),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(
                title: 'Workspace actif',
                subtitle: 'Votre contexte de travail actuel',
              ),
              const SizedBox(height: AppSpacing.sm),
              _WorkspaceCard(workspace: overview.workspace, onTap: onWorkspace),
              const SizedBox(height: AppSpacing.sectionGap),
              SectionHeader(
                title: 'Comptes sociaux',
                subtitle:
                    '${overview.connectedAccountsCount} sur ${overview.socialAccounts.length} connectés',
                actionLabel: 'Gérer',
                onAction: onSocialAccounts,
              ),
              const SizedBox(height: AppSpacing.sm),
              _SocialAccountsCard(accounts: overview.socialAccounts),
              const SizedBox(height: AppSpacing.sectionGap),
              const SectionHeader(
                title: 'Organisation',
                subtitle: 'Marque, équipe et automatisations',
              ),
              const SizedBox(height: AppSpacing.sm),
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
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.groups_outlined,
                      title: 'Équipe et permissions',
                      subtitle: '${overview.workspace.membersCount} membres',
                      onTap: onTeam,
                    ),
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.fact_check_outlined,
                      title: 'Validations',
                      subtitle: 'Flux de revue des contenus',
                      onTap: onApprovals,
                    ),
                    const Divider(height: 1),
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
              const SizedBox(height: AppSpacing.sm),
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
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: 'Canaux et fréquence des alertes',
                      onTap: onNotifications,
                    ),
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.security_outlined,
                      title: 'Sécurité',
                      subtitle: 'Accès et sessions actives',
                      onTap: onSecurity,
                    ),
                    const Divider(height: 1),
                    _ProfileTile(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      subtitle: 'Langue, thème et préférences',
                      onTap: onSettings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppAvatar(label: identity.name, size: AppAvatarSize.large),
          const SizedBox(height: AppSpacing.md),
          Text(
            identity.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            identity.email,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppBadge(
            label: 'Plan ${identity.planName}',
            icon: Icons.workspace_premium_outlined,
            tone: AppBadgeTone.info,
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
          const SizedBox(width: AppSpacing.md),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 320;
          if (stacked) {
            return Column(
              children: [
                for (var index = 0; index < accounts.length; index++) ...[
                  _SocialAccountStatus(
                    account: accounts[index],
                    expanded: true,
                  ),
                  if (index < accounts.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          }
          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final account in accounts)
                _SocialAccountStatus(account: account),
            ],
          );
        },
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

class _SocialAccountStatus extends StatelessWidget {
  const _SocialAccountStatus({required this.account, this.expanded = false});

  final ProfileSocialAccount account;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusLabel = account.isConnected ? 'Connecté' : 'Non connecté';
    return Semantics(
      container: true,
      label: '${account.platform.label}, $statusLabel',
      child: ExcludeSemantics(
        child: SizedBox(
          width: expanded ? double.infinity : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.72),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  SocialPlatformIcon(
                    platform: account.platform,
                    size: AppSizes.iconExtraSmall,
                    contained: false,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (expanded)
                    Expanded(
                      child: Text(
                        account.platform.label,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  else
                    Text(
                      account.platform.label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  SocialPlatformStatus(
                    label: statusLabel,
                    tone:
                        account.isConnected
                            ? SocialPlatformStatusTone.success
                            : SocialPlatformStatusTone.neutral,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
