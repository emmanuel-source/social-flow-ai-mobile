import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../shared/widgets/action_tile.dart';

class CreateHubScreen extends StatelessWidget {
  const CreateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créer',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF11143B),
                  Color(0xFF6D28D9),
                  Color(0xFF2563EB),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Que voulez-vous créer aujourd'hui ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Créez manuellement ou laissez SocialFlow AI vous guider.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                SearchBar(
                  leading: const Icon(Icons.auto_awesome),
                  hintText: "Demandez à l'assistant IA…",
                  onTap:
                      () => Navigator.pushNamed(context, AppRoutes.aiAssistant),
                  readOnly: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.12,
            children: [
              ActionTile(
                icon: Icons.collections_outlined,
                title: 'Publication',
                subtitle: 'Image, vidéo, carrousel',
                onTap: () => Navigator.pushNamed(context, AppRoutes.postType),
              ),
              ActionTile(
                icon: Icons.perm_media_outlined,
                title: 'Bibliothèque',
                subtitle: 'Tous vos médias',
                onTap:
                    () => Navigator.pushNamed(context, AppRoutes.mediaLibrary),
              ),
              ActionTile(
                icon: Icons.content_cut,
                title: 'Transformer une vidéo',
                subtitle: 'Reels et Shorts',
                onTap:
                    () => Navigator.pushNamed(context, AppRoutes.videoSource),
              ),
              ActionTile(
                icon: Icons.play_circle_outline,
                title: 'Importer YouTube',
                subtitle: 'Analyser un lien',
                onTap:
                    () => Navigator.pushNamed(context, AppRoutes.youtubeImport),
              ),
              ActionTile(
                icon: Icons.auto_awesome,
                title: 'Campagne IA',
                subtitle: 'Objectif vers contenu',
                onTap: () => Navigator.pushNamed(context, AppRoutes.campaign),
              ),
              ActionTile(
                icon: Icons.trending_up,
                title: 'Tendances',
                subtitle: 'Opportunités du moment',
                onTap: () => Navigator.pushNamed(context, AppRoutes.trends),
              ),
              ActionTile(
                icon: Icons.palette_outlined,
                title: 'Brand Kit',
                subtitle: 'Identité de marque',
                onTap: () => Navigator.pushNamed(context, AppRoutes.brandKit),
              ),
              ActionTile(
                icon: Icons.edit_note_outlined,
                title: 'Brouillons',
                subtitle: 'Reprendre un contenu',
                onTap: () => Navigator.pushNamed(context, AppRoutes.drafts),
              ),
              ActionTile(
                icon: Icons.smart_toy_outlined,
                title: 'Agents',
                subtitle: 'Automatisations',
                onTap: () => Navigator.pushNamed(context, AppRoutes.agents),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
