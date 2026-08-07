# SocialFlow AI — Flutter Starter Architecture v2

Cette base fusionne trois références :

1. le prototype interactif SocialFlow AI (38 écrans) ;
2. l’architecture Flutter préparée précédemment ;
3. la vision produit complète : workspaces, multi-réseaux, studio média/vidéo, IA, calendrier, analytics, inbox, automatisations, équipes et abonnements.

## Commencer ici

Lire dans cet ordre :

1. `docs/START_HERE.md`
2. `docs/ARCHITECTURE.md`
3. `docs/MODULE_MAPPING.md`
4. `docs/IMPLEMENTATION_ORDER.md`
5. `docs/BACKEND_CONTRACT.md`

## Navigation UX conservée

La navigation principale reste volontairement limitée à 5 destinations :

- Accueil
- Créer
- Calendrier
- Statistiques
- Profil

Les modules techniques vivent derrière ces 5 entrées et ne doivent pas être confondus avec la navigation visuelle.

## Packages intégrés

- `dio ^5.9.0` : API authentifiée principale
- `cached_network_image ^3.4.1` : images réseau avec cache
- `http ^1.6.0` : appels HTTP publics simples et isolés
- `flutter_riverpod ^3.1.0` : état + injection de dépendances
- `flutter_cache_manager ^3.4.1` : cache fichiers
- `hive ^2.2.3` / `hive_flutter ^1.1.0` : préférences, session, brouillons, jobs
- `path_provider ^2.1.5` : dossiers locaux
- `share_plus ^12.0.1` : partage natif
- `app_links ^6.4.1` : deep links / callbacks
- `image_picker ^1.2.1` : import médias
- `flutter_image_compress ^2.4.0` : compression image avant upload
- `fl_chart ^1.2.0` : statistiques

## Référence visuelle

Le prototype HTML original est conservé dans `docs/prototype_reference/` et reste la référence des parcours déjà validés.

## Important

Cette base est une architecture de démarrage. Les écrans du prototype sont présents, et les modules futurs importants sont structurés avec des contrats/squelettes. Le backend reste la source de vérité pour OAuth social, publication réelle, quotas, facturation, jobs IA et analytics agrégés.

## Collaborative development

Before coding with multiple contributors or Codex agents, read:

- `AGENTS.md`
- `docs/development/FIRST_DAY.md`
- `docs/development/COLLABORATION_GUIDE.md`
- `docs/development/CODEX_WORKFLOW.md`
- `docs/development/SPRINT_1.md`

GitHub `main` is the source of truth. One task uses one branch, and parallel agents use isolated branches/worktrees.
