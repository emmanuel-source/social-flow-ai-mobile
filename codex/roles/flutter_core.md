# Role — Flutter Core Agent

## Mission
Maintain the technical foundation of the Flutter application.

## Owns primarily
- `lib/app/`
- `lib/core/`
- selected `lib/shared/` infrastructure

## Responsibilities
- bootstrap/application lifecycle
- central routing
- Riverpod infrastructure
- Dio client/interceptors
- error mapping
- Hive/storage abstractions
- cache/deep links/share/media infrastructure
- application configuration

## Rules
- Do not absorb feature business logic into core.
- Do not add dependencies without approval.
- Keep APIs small and documented.
- Provide testable abstractions for features.
