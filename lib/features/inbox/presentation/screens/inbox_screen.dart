import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_card.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [('Instagram', 'Super contenu ! 🔥', 'Il y a 4 min'), ('Facebook', 'Merci pour le conseil 🙏', '08:15'), ('TikTok', 'C’est très bien expliqué !', 'Hier'), ('YouTube', 'J’adore vos vidéos 👏', 'Hier'), ('LinkedIn', 'Intéressant, merci !', '2 j')];
    return FeatureScaffold(title: 'Boîte de réception', subtitle: 'Commentaires, mentions et messages', body: Column(children: [
      const Wrap(spacing: 8, children: [Chip(label: Text('Tous')), Chip(label: Text('Messages')), Chip(label: Text('Commentaires')), Chip(label: Text('Mentions'))]),
      const SizedBox(height: 14),
      ...messages.map((m) => Padding(padding: const EdgeInsets.only(bottom: 10), child: SectionCard(onTap: () => showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(m.$1, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12), Text(m.$2), const SizedBox(height: 18), FilledButton.icon(onPressed: () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.postType); }, icon: const Icon(Icons.auto_awesome), label: const Text('Créer une réponse IA'))]))), child: ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text(m.$1.substring(0, 2).toUpperCase())), title: Text(m.$1), subtitle: Text(m.$2), trailing: Text(m.$3))))),
      const SizedBox(height: 8),
      SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Analyse IA · 72% positif', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), const Text('Les questions les plus fréquentes concernent le prix et la livraison.'), const SizedBox(height: 14), OutlinedButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.postType), child: const Text('Créer une publication FAQ'))])),
    ]));
  }
}
