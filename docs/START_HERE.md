# START HERE — SocialFlow AI

## 1. La règle principale

SocialFlow AI doit évoluer sans transformer `lib/` en un grand dossier où tous les écrans, APIs et états se connaissent.

Nous utilisons donc une architecture **feature-first** : chaque fonctionnalité possède son espace, ses modèles métier, ses accès aux données et son interface.

## 2. Les 5 onglets ne sont pas les modules

La navigation utilisateur reste :

1. **Accueil** — résumé, actions rapides, alertes
2. **Créer** — hub de création
3. **Calendrier** — programmation et planning
4. **Statistiques** — performance
5. **Profil** — workspace, comptes, équipe, abonnement, paramètres

Derrière ces onglets, l’application contient plusieurs modules techniques indépendants.

## 3. Les modules à construire en priorité

### MVP

- auth + onboarding
- workspaces
- social_accounts
- content
- media_library
- publishing
- drafts
- calendar
- ai_assistant
- analytics

### Phase 2

- video_studio
- campaigns
- brand_kit
- inbox
- agents
- notifications

### Phase 3

- team
- approvals
- subscriptions
- fonctions agence avancées

## 4. Flux principal cible

`Créer/importer → choisir le contenu → choisir les comptes/réseaux → adaptation par plateforme → preview par réseau → publier maintenant / programmer / brouillon → suivre l’état → analytics`

Le Studio vidéo ajoute en amont :

`vidéo longue / lien YouTube → analyse → highlights → clips → recadrage → sous-titres → retour dans le composer`

## 5. Frontend vs backend

Flutter gère :

- navigation et UX ;
- formulaires et previews ;
- cache et état local ;
- brouillons ;
- sélection/compression média ;
- affichage des jobs, résultats et statistiques.

Le backend gère :

- tokens sociaux et OAuth ;
- publication réelle vers les plateformes ;
- scheduling fiable ;
- workers IA/vidéo ;
- règles de quotas ;
- facturation ;
- permissions finales ;
- analytics consolidés.

## 6. Règle de dépendance

Un écran ne doit jamais appeler Dio directement.

`Screen/Widget → Controller/Provider → Repository contract → Repository implementation → Dio/Hive/service`

Les modules ne doivent pas importer les écrans d’un autre module pour partager de la logique. Les objets réellement communs vont dans `shared/` ; les services techniques communs vont dans `core/`.
