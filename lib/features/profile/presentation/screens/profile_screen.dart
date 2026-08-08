import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../workspaces/presentation/controllers/workspace_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceControllerProvider).current;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  child: Text(
                    'SM',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Sarah Miller',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                Text('SocialFlow AI'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.workspaces_outline),
            title: const Text('Espace de travail'),
            subtitle: Text(workspace.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.workspaces),
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Comptes sociaux'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.accounts),
          ),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Équipe et permissions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.team),
          ),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('Validations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.approvals),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Abonnement'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Sécurité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.security),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Paramètres'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}
