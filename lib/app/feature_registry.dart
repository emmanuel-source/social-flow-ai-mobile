enum FeatureStage { mvp, phase2, phase3 }

class FeatureDefinition {
  const FeatureDefinition({
    required this.key,
    required this.label,
    required this.stage,
    required this.description,
  });

  final String key;
  final String label;
  final FeatureStage stage;
  final String description;
}

abstract final class FeatureRegistry {
  static const all = <FeatureDefinition>[
    FeatureDefinition(
      key: 'auth',
      label: 'Auth & onboarding',
      stage: FeatureStage.mvp,
      description: 'Entrée dans l’application et session utilisateur.',
    ),
    FeatureDefinition(
      key: 'workspaces',
      label: 'Workspaces',
      stage: FeatureStage.mvp,
      description: 'Séparation des marques, clients et espaces.',
    ),
    FeatureDefinition(
      key: 'social_accounts',
      label: 'Comptes sociaux',
      stage: FeatureStage.mvp,
      description: 'Connexions aux plateformes.',
    ),
    FeatureDefinition(
      key: 'content',
      label: 'Création de contenu',
      stage: FeatureStage.mvp,
      description: 'Composer texte, image, vidéo ou carrousel.',
    ),
    FeatureDefinition(
      key: 'media_library',
      label: 'Bibliothèque média',
      stage: FeatureStage.mvp,
      description: 'Centraliser les ressources média.',
    ),
    FeatureDefinition(
      key: 'publishing',
      label: 'Publication',
      stage: FeatureStage.mvp,
      description: 'Publier immédiatement ou programmer.',
    ),
    FeatureDefinition(
      key: 'calendar',
      label: 'Calendrier',
      stage: FeatureStage.mvp,
      description: 'Visualiser le planning éditorial.',
    ),
    FeatureDefinition(
      key: 'drafts',
      label: 'Brouillons',
      stage: FeatureStage.mvp,
      description: 'Sauvegarder et reprendre les créations.',
    ),
    FeatureDefinition(
      key: 'ai_assistant',
      label: 'Assistant IA',
      stage: FeatureStage.mvp,
      description: 'Idées, légendes, scripts et adaptation.',
    ),
    FeatureDefinition(
      key: 'analytics',
      label: 'Statistiques',
      stage: FeatureStage.mvp,
      description: 'Performance globale et par publication.',
    ),
    FeatureDefinition(
      key: 'video_studio',
      label: 'Studio vidéo',
      stage: FeatureStage.phase2,
      description: 'Long format vers clips, sous-titres et reframe.',
    ),
    FeatureDefinition(
      key: 'campaigns',
      label: 'Campagnes',
      stage: FeatureStage.phase2,
      description: 'Regrouper du contenu autour d’un objectif.',
    ),
    FeatureDefinition(
      key: 'brand_kit',
      label: 'Brand Kit',
      stage: FeatureStage.phase2,
      description: 'Identité, ton et règles de marque.',
    ),
    FeatureDefinition(
      key: 'inbox',
      label: 'Inbox',
      stage: FeatureStage.phase2,
      description: 'Commentaires et interactions prioritaires.',
    ),
    FeatureDefinition(
      key: 'agents',
      label: 'Agents IA',
      stage: FeatureStage.phase2,
      description: 'Automatisations contrôlées.',
    ),
    FeatureDefinition(
      key: 'notifications',
      label: 'Notifications',
      stage: FeatureStage.phase2,
      description: 'Événements importants et résultats de jobs.',
    ),
    FeatureDefinition(
      key: 'team',
      label: 'Équipe',
      stage: FeatureStage.phase3,
      description: 'Rôles et collaboration.',
    ),
    FeatureDefinition(
      key: 'approvals',
      label: 'Validations',
      stage: FeatureStage.phase3,
      description: 'Workflow agence/client.',
    ),
    FeatureDefinition(
      key: 'subscriptions',
      label: 'Abonnements',
      stage: FeatureStage.phase3,
      description: 'Plans, quotas et droits.',
    ),
  ];
}
