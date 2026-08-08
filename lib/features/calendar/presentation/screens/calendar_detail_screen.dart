import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/feature_scaffold.dart';

class CalendarDetailScreen extends StatelessWidget {
  const CalendarDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Publication programmée',
      subtitle: "Aujourd'hui · 10:00",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppNetworkImage(
            url:
                'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=1200',
          ),
          const SizedBox(height: 14),
          const Text(
            '5 astuces simples pour booster votre productivité au quotidien ! 🚀',
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.postCaption),
            child: const Text('Modifier'),
          ),
          OutlinedButton(
            onPressed:
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Publication dupliquée dans les brouillons.'),
                  ),
                ),
            child: const Text('Dupliquer'),
          ),
          TextButton(onPressed: () {}, child: const Text('Reprogrammer')),
        ],
      ),
    );
  }
}
