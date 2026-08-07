# Ordre d'implémentation recommandé

## Sprint 0 — Fondation

- lancer `flutter create` si les dossiers Android/iOS ne sont pas encore présents ;
- conserver `lib`, `assets`, `test`, `docs` de cette base ;
- configurer `.env` via `--dart-define` ou la stratégie backend retenue ;
- lancer `flutter pub get`, `flutter analyze`, `flutter test` ;
- brancher l'URL du backend de développement.

## Sprint 1 — Session + Workspace

1. auth réelle ;
2. persistance de session ;
3. récupération des workspaces ;
4. workspace actif ;
5. comptes sociaux appartenant au workspace.

Pourquoi d'abord : presque tous les autres endpoints dépendent de `workspace_id`.

## Sprint 2 — Composer MVP

1. type de publication ;
2. médias ;
3. caption ;
4. comptes/réseaux cibles ;
5. preview ;
6. brouillon ;
7. publier maintenant / programmer.

Objectif : rendre fonctionnel le parcours central du prototype avant les fonctions avancées.

## Sprint 3 — Calendrier + file de publication

- calendrier réel ;
- statut `draft / pending / scheduled / publishing / published / failed` ;
- détail de publication ;
- retry sécurisé côté backend.

## Sprint 4 — Assistant IA

- génération de légende ;
- variantes par plateforme ;
- hashtags ;
- scripts ;
- traduction ;
- historique de génération.

## Sprint 5 — Analytics MVP

- résumé du workspace ;
- performance par plateforme ;
- performance par publication ;
- périodes et filtres.

## Phase suivante

Une fois le cœur stable : Studio vidéo → Campagnes/Brand Kit → Inbox → Agents → Équipe/Validations → Abonnements.

Ne pas commencer par automatiser toutes les plateformes ou construire les agents avant que le flux simple `composer → publish → calendar → analytics` soit fiable.
