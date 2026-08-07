# Configuration des deep links

Schéma prévu :

```text
socialflow://create
socialflow://post/{postId}
socialflow://calendar/{postId}
socialflow://agent/{agentId}
socialflow://inbox
```

Liens HTTPS possibles :

```text
https://app.socialflow.ai/post/{postId}
https://app.socialflow.ai/calendar/{postId}
```

## Android

Ajoutez un `intent-filter` dans l’activité principale pour le schéma `socialflow` et un filtre vérifié pour `https://app.socialflow.ai`.

## iOS

Ajoutez `socialflow` dans `CFBundleURLTypes`, puis configurez Associated Domains avec `applinks:app.socialflow.ai`.

Le service `DeepLinkService` est instancié dès le démarrage afin de recevoir les liens à froid et à chaud.
