# Module Mapping — prototype + vision produit

| Module | Rôle | Prototype existant | Priorité |
|---|---|---|---|
| onboarding | présentation initiale | onboarding1/2/3 | MVP |
| auth | connexion/session | login | MVP |
| home | tableau de bord | home | MVP |
| workspaces | marque/entreprise/agence/client actif | nouveau | MVP |
| social_accounts | comptes connectés | accounts | MVP |
| content | composer multiréseaux | postType → postSuccess | MVP |
| media_library | ressources réutilisables | nouveau | MVP |
| publishing | file, statuts, retries | partiellement postSchedule/postSuccess | MVP |
| drafts | sauvegarde/reprise | nouveau | MVP |
| calendar | planning éditorial | calendar/calendarDetail | MVP |
| ai_assistant | idées, légendes, scripts, adaptation | extension du Create hub | MVP |
| analytics | performance | stats/statsPost | MVP |
| video_studio | long format → clips | videoSource → subtitles | Phase 2 |
| campaigns | campagne + tendances | campaign/trends | Phase 2 |
| brand_kit | identité de marque | brandKit | Phase 2 |
| inbox | commentaires/interactions | inbox | Phase 2 |
| agents | automatisations IA | agents → agentDetail | Phase 2 |
| notifications | événements importants | nouveau | Phase 2 |
| team | membres/rôles | nouveau | Phase 3 |
| approvals | workflow validation | nouveau | Phase 3 |
| subscriptions | plans/quotas | nouveau | Phase 3 |
| profile | compte utilisateur | profile | transversal |
| security | sessions/2FA/révocation | nouveau | transversal |
| settings | préférences app | settings | transversal |

## Plateformes préparées

`Instagram, Facebook, TikTok, YouTube, Snapchat, X, LinkedIn, Pinterest, Threads`

La présence dans l'enum Flutter ne signifie pas qu'une API de publication est disponible automatiquement. La disponibilité réelle doit être pilotée par le backend et les autorisations de chaque plateforme.
