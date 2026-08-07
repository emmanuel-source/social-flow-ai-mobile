import 'package:flutter/material.dart';

class FutureFeatureScreen extends StatelessWidget {
  const FutureFeatureScreen({
    required this.title,
    required this.description,
    required this.icon,
    this.items = const [],
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF11143B), Color(0xFF6D28D9), Color(0xFF2563EB)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 38, color: Colors.white),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: Colors.white70, height: 1.4)),
              ],
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Périmètre du module', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ...items.map((item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(item),
                )),
          ],
        ],
      ),
    );
  }
}
