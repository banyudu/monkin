#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-}"
DMG="$ROOT_DIR/dist/Monkin-${VERSION}.dmg"

if [[ -z "$VERSION" || ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$ ]]; then
  echo "Usage: $0 VERSION" >&2
  exit 2
fi

cd "$ROOT_DIR"
if [[ -n "$(git status --short)" ]]; then
  echo "Working tree is not clean; commit release changes first." >&2
  exit 1
fi

IDENTITY="${MONKIN_SIGNING_IDENTITY:-}"
if [[ -z "$IDENTITY" ]]; then
  IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
    | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' | head -n 1)"
fi
if [[ -z "$IDENTITY" ]]; then
  echo "No Developer ID Application certificate found." >&2
  exit 1
fi

echo "Building Monkin $VERSION with: $IDENTITY"
MONKIN_VERSION="$VERSION" \
MONKIN_SKIP_INSTALL=1 \
MONKIN_SIGNING_IDENTITY="$IDENTITY" \
  "$ROOT_DIR/scripts/package-app.sh"

rm -f "$DMG"
hdiutil create -volname "Monkin $VERSION" -srcfolder "$ROOT_DIR/dist/Monkin.app" \
  -ov -format UDZO "$DMG"
codesign --verify --deep --strict "$ROOT_DIR/dist/Monkin.app"
hdiutil verify "$DMG"

git push origin HEAD
gh release create "v${VERSION}" "$DMG" --target "$(git rev-parse HEAD)" \
  --title "Monkin $VERSION" --generate-notes

echo "Published: $DMG"
