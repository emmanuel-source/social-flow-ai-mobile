# Architecture SocialFlow AI v2

## Vue globale

```text
lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── app_router.dart
│   ├── app_routes.dart
│   ├── app_shell.dart
│   └── feature_registry.dart
├── core/
│   ├── cache/
│   ├── config/
│   ├── constants/
│   ├── deep_links/
│   ├── errors/
│   ├── media/
│   ├── network/
│   ├── share/
│   ├── storage/
│   ├── theme/
│   └── utils/
├── shared/
│   ├── models/
│   ├── providers/
│   └── widgets/
└── features/
    ├── onboarding/
    ├── auth/
    ├── home/
    ├── workspaces/
    ├── social_accounts/
    ├── content/
    ├── media_library/
    ├── publishing/
    ├── drafts/
    ├── video_studio/
    ├── campaigns/
    ├── brand_kit/
    ├── ai_assistant/
    ├── calendar/
    ├── analytics/
    ├── inbox/
    ├── agents/
    ├── notifications/
    ├── team/
    ├── approvals/
    ├── subscriptions/
    ├── profile/
    ├── security/
    └── settings/
```

## Architecture interne d'un module

Un module peut contenir :

```text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/        # seulement si la logique le justifie
└── presentation/
    ├── controllers/
    ├── screens/
    └── widgets/
```

Ne pas créer mécaniquement toutes les couches si elles sont vides. On les ajoute au moment où le module reçoit une vraie logique.

## Riverpod

Riverpod sert à :

- injection des repositories/services ;
- état de session ;
- workspace actif ;
- composer ;
- jobs vidéo/IA ;
- chargement API ;
- filtres analytics ;
- états de formulaire complexes.

Un `StatefulWidget` reste acceptable pour un état strictement visuel local (index, animation, champ temporaire).

## Réseau

`DioClient` est le client API principal. Il doit centraliser :

- base URL ;
- headers ;
- bearer token ;
- timeouts ;
- mapping erreurs ;
- refresh token futur ;
- upload progress.

Le package `http` est conservé uniquement pour des usages publics simples qui ne doivent pas traverser la pile Dio principale.

## Stockage

Hive doit rester réservé aux données locales utiles :

- préférences ;
- auth/session légère ;
- workspace sélectionné ;
- brouillons ;
- cache de jobs ;
- données de reprise hors ligne.

Les tokens OAuth des réseaux sociaux ne doivent pas être considérés comme une donnée métier à conserver librement dans l’application : le backend doit les protéger.

## Média

`image_picker` → choix média

`flutter_image_compress` → optimisation avant upload

`path_provider` → fichiers temporaires/exports

`flutter_cache_manager` + `cached_network_image` → cache réseau

## Deep links

`app_links` gère les liens entrants, par exemple :

- ouverture d’une publication ;
- invitation à un workspace ;
- retour depuis un parcours web/OAuth ;
- validation de contenu.

Le parseur transforme le lien en route interne. L’écran n’analyse pas directement l’URI.

## Analytics

`fl_chart` est utilisé uniquement dans la couche présentation. Les agrégats et calculs métier viennent d’un repository Analytics ou du backend.
