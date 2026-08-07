#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter n'est pas installé ou n'est pas dans le PATH." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
cp -R "$ROOT/lib" "$TMP/lib"
cp "$ROOT/pubspec.yaml" "$TMP/pubspec.yaml"
cp "$ROOT/analysis_options.yaml" "$TMP/analysis_options.yaml"

cd "$ROOT"
flutter create --org com.socialflowai --platforms=android,ios,web .
rm -rf "$ROOT/lib"
cp -R "$TMP/lib" "$ROOT/lib"
cp "$TMP/pubspec.yaml" "$ROOT/pubspec.yaml"
cp "$TMP/analysis_options.yaml" "$ROOT/analysis_options.yaml"
flutter pub get

echo "Plateformes générées. Configurez maintenant les deep links selon docs/DEEP_LINKS_SETUP.md."
