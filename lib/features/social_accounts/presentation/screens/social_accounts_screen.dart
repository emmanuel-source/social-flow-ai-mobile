import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_scaffold.dart';

class SocialAccountsScreen extends StatelessWidget {
  const SocialAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = [('Instagram', '@sarahcreates', true), ('Facebook', 'Sarah Miller Studio', true), ('TikTok', '@sarahcreates', true), ('YouTube', 'Sarah Miller', true), ('LinkedIn', 'Non connecté', false), ('X', 'Non connecté', false)];
    return FeatureScaffold(title: 'Comptes sociaux', subtitle: 'Connexions OAuth et permissions', body: Column(children: accounts.map((account) => ListTile(leading: CircleAvatar(child: Text(account.$1.substring(0, 2).toUpperCase())), title: Text(account.$1), subtitle: Text(account.$2), trailing: account.$3 ? OutlinedButton(onPressed: () {}, child: const Text('Gérer')) : FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connexion ${account.$1} ouverte.'))), child: const Text('Connecter')))).toList()));
  }
}
