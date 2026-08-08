#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter n'est pas installe ou n'est pas dans PATH." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for required_path in pubspec.yaml android ios web; do
  if [[ ! -e "$ROOT/$required_path" ]]; then
    echo "Structure Flutter incomplete : '$required_path' est absent. Restaurez-le depuis Git avant de continuer." >&2
    exit 1
  fi
done

cd "$ROOT"
flutter --version
dart --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test

if [[ "${1:-}" == "--build" ]]; then
  flutter build web
  flutter build apk --debug
fi

echo "Fondation Flutter validee."
