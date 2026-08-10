import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_state_view.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_content.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({required this.onLogout, super.key});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: profile.when(
          loading:
              () => const AppLoader(
                key: Key('profile-loading'),
                label: 'Chargement du profil',
              ),
          error:
              (error, stackTrace) => AppErrorState(
                key: const Key('profile-error'),
                title: 'Le profil est indisponible',
                message:
                    'Impossible de charger vos informations pour le moment.',
                onRetry: ref.read(profileControllerProvider.notifier).reload,
              ),
          data:
              (overview) => ProfileContent(
                overview: overview,
                onWorkspace: () => _open(context, AppRoutes.workspaces),
                onSocialAccounts: () => _open(context, AppRoutes.accounts),
                onBrandKit: () => _open(context, AppRoutes.brandKit),
                onTeam: () => _open(context, AppRoutes.team),
                onApprovals: () => _open(context, AppRoutes.approvals),
                onAgents: () => _open(context, AppRoutes.agents),
                onSubscription: () => _open(context, AppRoutes.subscription),
                onNotifications: () => _open(context, AppRoutes.notifications),
                onSecurity: () => _open(context, AppRoutes.security),
                onSettings: () => _open(context, AppRoutes.settings),
                onLogout: () => _confirmLogout(context),
              ),
        ),
      ),
    );
  }

  void _open(BuildContext context, String route) =>
      Navigator.pushNamed(context, route);

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Se déconnecter ?',
      message:
          'Vous devrez vous reconnecter pour accéder à votre espace de travail.',
      confirmLabel: 'Se déconnecter',
      destructive: true,
    );
    if (confirmed == true) await onLogout();
  }
}
