#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/Monkin.xcodeproj"
SCHEME="Monkin"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/Monkin.app"
INSTALL_DIR="${MONKIN_INSTALL_DIR:-/Applications}"
INSTALLED_APP="$INSTALL_DIR/Monkin.app"
SCREENSAVER_DIR="${MONKIN_SCREENSAVER_DIR:-$HOME/Library/Screen Savers}"
INSTALLED_SCREENSAVER="$SCREENSAVER_DIR/Monkin.saver"
VERSION="${MONKIN_VERSION:-0.1.0}"
BUILD_DIR="$ROOT_DIR/.build/xcode"

cd "$ROOT_DIR"
xcodegen generate >/dev/null

SIGNING_IDENTITY="${MONKIN_SIGNING_IDENTITY:-${APPLE_SIGNING_IDENTITY_DEV:-}}"
if [[ -z "$SIGNING_IDENTITY" ]]; then
  SIGNING_IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null \
    | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' | head -n 1)"
fi
if [[ -z "$SIGNING_IDENTITY" ]]; then
  echo "No Developer ID Application certificate found." >&2
  exit 1
fi

rm -rf "$BUILD_DIR"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  build \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  DEVELOPMENT_TEAM=RYLS8UDY5D \
  PRODUCT_BUNDLE_IDENTIFIER=com.banyudu.monkin \
  MARKETING_VERSION="$VERSION" \
  CURRENT_PROJECT_VERSION="${MONKIN_BUILD:-$(git rev-parse --short HEAD 2>/dev/null || echo local)}"

xcodebuild \
  -project "$PROJECT" \
  -scheme MonkinScreenSaver \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  build \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  DEVELOPMENT_TEAM=RYLS8UDY5D \
  PRODUCT_BUNDLE_IDENTIFIER=com.banyudu.monkin.screensaver \
  MARKETING_VERSION="$VERSION" \
  CURRENT_PROJECT_VERSION="${MONKIN_BUILD:-$(git rev-parse --short HEAD 2>/dev/null || echo local)}"

BUILT_APP="$BUILD_DIR/Build/Products/Release/Monkin.app"
BUILT_SCREENSAVER="$BUILD_DIR/Build/Products/Release/Monkin.saver"
rm -rf "$APP_DIR"
rm -rf "$DIST_DIR/Monkin.saver"
mkdir -p "$DIST_DIR"
ditto "$BUILT_APP" "$APP_DIR"
ditto "$BUILT_SCREENSAVER" "$DIST_DIR/Monkin.saver"

codesign --verify --deep --strict "$APP_DIR"
codesign --verify --deep --strict "$DIST_DIR/Monkin.saver"
echo "Signed with: $SIGNING_IDENTITY"
echo "Packaged: $APP_DIR"
echo "Packaged: $DIST_DIR/Monkin.saver"

if [[ "${MONKIN_SKIP_INSTALL:-0}" == "1" ]]; then
  echo "Skipped install (MONKIN_SKIP_INSTALL=1)"
  exit 0
fi

if [[ -d "$INSTALLED_APP" ]]; then
  rm -rf "$DIST_DIR/Monkin-previous.app"
  ditto "$INSTALLED_APP" "$DIST_DIR/Monkin-previous.app"
  echo "Archived previous install to $DIST_DIR/Monkin-previous.app"
fi

if [[ -d "$INSTALLED_SCREENSAVER" ]]; then
  rm -rf "$DIST_DIR/Monkin-previous.saver"
  ditto "$INSTALLED_SCREENSAVER" "$DIST_DIR/Monkin-previous.saver"
  echo "Archived previous screensaver to $DIST_DIR/Monkin-previous.saver"
fi

rm -rf "$INSTALLED_APP"
ditto "$APP_DIR" "$INSTALLED_APP"
codesign --verify --deep --strict "$INSTALLED_APP"
echo "Installed: $INSTALLED_APP"

mkdir -p "$SCREENSAVER_DIR"
rm -rf "$INSTALLED_SCREENSAVER"
ditto "$DIST_DIR/Monkin.saver" "$INSTALLED_SCREENSAVER"
codesign --verify --deep --strict "$INSTALLED_SCREENSAVER"
echo "Installed screensaver: $INSTALLED_SCREENSAVER"
