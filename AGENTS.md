# Social Flow AI — Repository Agent Rules

These instructions apply to all human contributors and Codex agents working in this repository.

## 1. Product guardrails

Social Flow AI is a Flutter mobile application for multi-network social content creation, publishing, scheduling, media/video workflows, AI assistance, inbox/engagement and analytics.

The main mobile navigation has exactly five top-level destinations:

1. Home
2. Create
3. Calendar
4. Analytics
5. Profile

Feature modules may add nested screens, but must not add more top-level navigation tabs without an architecture decision record (ADR) and product-owner approval.

## 2. Architecture

Use feature-first Flutter architecture with pragmatic Clean Architecture boundaries.

Preferred flow inside a mature feature:

presentation -> domain -> data

Rules:
- `lib/core/` must not depend on feature presentation code.
- `lib/shared/` contains only genuinely cross-feature models/providers/widgets.
- A feature must not import another feature's presentation layer.
- Cross-feature interactions must use domain contracts, shared abstractions, application orchestration or routing.
- Do not create abstraction layers without a concrete need.

## 3. State management

Use `flutter_riverpod` only.

Do not introduce Bloc, GetX, MobX, Provider or another state-management framework.

Keep business state out of widgets. Widgets may own short-lived UI-only state when appropriate.

## 4. Networking

Use the shared Dio client from `lib/core/network/`.

Do not instantiate `Dio()` directly inside screens, widgets or feature controllers.

Use `http` only for explicitly isolated lightweight/public integrations where the architecture documents allow it.

All API errors must be converted into application/domain failures before reaching presentation.

## 5. Persistence and cache

Use shared repositories/services built over Hive and the cache layer.

Do not open Hive boxes directly from UI widgets.

Never persist access tokens in plain text logs, screenshots, debug messages or source files.

## 6. Media

Use the shared media services for picking, compression, cache and local paths.

Do not duplicate image compression or cache logic inside features.

## 7. Design system

The UI/UX Design Agent owns the design system and shared UI primitives.

Use tokens/components from:
- `lib/core/theme/`
- `lib/shared/widgets/`

Avoid hard-coded colors, spacing, typography, radius and shadows when a token exists.

Before adding a new reusable component, search for an equivalent component.

Preserve the current Social Flow AI visual direction: modern, premium, clean, AI-oriented, with the established purple/blue identity unless a product decision changes it.

Every production screen must consider:
- loading
- empty
- error
- success/content
- disabled/permission state when relevant
- mobile responsiveness and safe areas
- accessibility labels for important interactive controls

## 8. Routing

Use the central application router.

Do not create independent nested navigation systems without an architecture reason.

Deep links must be handled by the central deep-link service/router.

## 9. Testing and quality

Before declaring a task complete, run when applicable:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Add tests for new business logic and regression fixes.

Do not silence analyzer warnings merely to make CI green.

## 10. Git workflow

Never work directly on `main`.

One task = one branch.

Branch naming:
- `feat/SFA-<id>-short-name`
- `fix/SFA-<id>-short-name`
- `refactor/SFA-<id>-short-name`
- `chore/SFA-<id>-short-name`

Keep pull requests focused. Avoid unrelated refactors.

Do not merge a pull request while CI is failing.

## 11. Multi-agent safety

Each coding agent must work in its own Git branch/worktree or isolated Codex task environment.

Do not allow two agents to modify the same feature area concurrently unless the Orchestrator explicitly coordinates ownership.

Default maximum parallel coding tasks: 3.

The Orchestrator must define file/module ownership before parallel work begins.

## 12. Scope discipline

Read the assigned task and acceptance criteria before editing.

Do not modify files outside the task scope unless strictly necessary.

If a task requires an architectural change, dependency change or shared-contract change, report it to the Orchestrator before expanding scope.

## 13. Dependencies

Do not add, remove or upgrade Flutter packages without explicit task scope or Orchestrator approval.

Current core package choices include Riverpod, Dio, Hive, cached_network_image, flutter_cache_manager, app_links, share_plus, image_picker, flutter_image_compress and fl_chart.

## 14. Secrets

Never commit API keys, OAuth secrets, passwords, private certificates or production credentials.

Use `.env.example` for documented variable names only.

## 15. Definition of done

A task is complete only when:
- acceptance criteria are satisfied;
- code follows architecture and design-system rules;
- formatting/analyzer/tests pass where applicable;
- loading/error/empty states are handled where relevant;
- documentation is updated when contracts or behavior changed;
- the pull request describes what changed and how it was verified.
