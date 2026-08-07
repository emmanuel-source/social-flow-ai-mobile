import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/feature_scaffold.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _weeklyReport = true;

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(themeControllerProvider) == ThemeMode.dark;
    return FeatureScaffold(title: 'Paramètres', subtitle: 'Préférences de l’application', body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SwitchListTile(value: dark, onChanged: ref.read(themeControllerProvider.notifier).setDarkMode, title: const Text('Mode sombre')),
      SwitchListTile(value: _notifications, onChanged: (value) => setState(() => _notifications = value), title: const Text('Notifications de publication')),
      SwitchListTile(value: _weeklyReport, onChanged: (value) => setState(() => _weeklyReport = value), title: const Text('Rapport hebdomadaire')),
      const ListTile(title: Text('Langue'), subtitle: Text('Français'), trailing: Icon(Icons.chevron_right)),
      const ListTile(title: Text('Fuseau horaire'), subtitle: Text('Africa/Johannesburg'), trailing: Icon(Icons.chevron_right)),
      const SizedBox(height: 20),
      FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Préférences enregistrées.'))), child: const Text('Enregistrer')),
    ]));
  }
}
