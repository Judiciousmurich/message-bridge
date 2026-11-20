#!/usr/bin/env bash
# Opens the release AAB folder in Finder for Play Console upload.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AAB="$ROOT/build/app/outputs/bundle/release/app-release.aab"
if [[ ! -f "$AAB" ]]; then
  echo "Missing $AAB — run: flutter build appbundle --release"
  exit 1
fi
echo "Bundle: $AAB"
echo "$AAB" | pbcopy
echo "Path copied to clipboard."
open -R "$AAB"