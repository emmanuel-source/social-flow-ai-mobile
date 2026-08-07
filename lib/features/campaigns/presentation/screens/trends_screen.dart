import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/feature_scaffold.dart';
import '../../../../shared/widgets/section_card.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trends = [('Productivité sans burnout', '+186%'), ('Coulisses authentiques', '+94%'), ('Mini tutoriels 30 sec', '+73%')];
    return FeatureScaffold(title: 'Tendances & idées', subtitle: 'Opportunités adaptées à votre audience', body: Column(children: trends.map((trend) => Padding(padding: const EdgeInsets.only(bottom: 12), child: SectionCard(child: ListTile(contentPadding: EdgeInsets.zero, title: Text(trend.$1), subtitle: Text('Potentiel de croissance ${trend.$2}'), trailing: IconButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.postCaption), icon: const Icon(Icons.add_circle_outline)))))).toList()));
  }
}
