# Contrat backend cible (proposition de structure)

Préfixe suggéré : `/api/v1/`

## Session

- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /me`

## Workspaces

- `GET /workspaces`
- `POST /workspaces`
- `GET /workspaces/{workspace_id}`
- `PATCH /workspaces/{workspace_id}`

## Comptes sociaux

- `GET /workspaces/{workspace_id}/social-accounts`
- `POST /workspaces/{workspace_id}/social-accounts/{platform}/connect`
- `DELETE /workspaces/{workspace_id}/social-accounts/{account_id}`

Le mobile ne doit pas être la source de vérité des tokens sociaux.

## Médias

- `POST /workspaces/{workspace_id}/media`
- `GET /workspaces/{workspace_id}/media`
- `DELETE /workspaces/{workspace_id}/media/{media_id}`

## Contenu / brouillons

- `GET /workspaces/{workspace_id}/drafts`
- `POST /workspaces/{workspace_id}/drafts`
- `PATCH /workspaces/{workspace_id}/drafts/{draft_id}`
- `DELETE /workspaces/{workspace_id}/drafts/{draft_id}`

## Publication

- `POST /workspaces/{workspace_id}/publications`
- `GET /workspaces/{workspace_id}/publications`
- `GET /workspaces/{workspace_id}/publications/{publication_id}`
- `POST /workspaces/{workspace_id}/publications/{publication_id}/retry`

Une publication doit retourner un statut global et des statuts par plateforme/compte.

## Calendrier

- `GET /workspaces/{workspace_id}/calendar?from=&to=`

## IA

- `POST /workspaces/{workspace_id}/ai/generate-caption`
- `POST /workspaces/{workspace_id}/ai/adapt-platforms`
- `POST /workspaces/{workspace_id}/ai/generate-script`
- `POST /workspaces/{workspace_id}/ai/translate`

## Studio vidéo

- `POST /workspaces/{workspace_id}/video-jobs`
- `GET /workspaces/{workspace_id}/video-jobs/{job_id}`
- `GET /workspaces/{workspace_id}/video-jobs/{job_id}/clips`

Les opérations longues sont des jobs asynchrones côté serveur ; Flutter ne doit pas encoder/traiter l'intégralité d'une longue vidéo en tâche métier principale.

## Analytics

- `GET /workspaces/{workspace_id}/analytics/overview`
- `GET /workspaces/{workspace_id}/analytics/posts/{publication_id}`
- `GET /workspaces/{workspace_id}/analytics/platforms/{platform}`

## Collaboration

- `GET /workspaces/{workspace_id}/members`
- `POST /workspaces/{workspace_id}/members/invite`
- `POST /workspaces/{workspace_id}/approvals`
- `POST /workspaces/{workspace_id}/approvals/{approval_id}/decision`

## Abonnement

- `GET /billing/plan`
- `GET /billing/usage`

Le backend doit appliquer les quotas, même si l'interface mobile les affiche déjà.
