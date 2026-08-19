#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEV_APP="$ROOT_DIR/.build/dev/Monkin.app"
PROJECT="$ROOT_DIR/Monkin.xcodeproj"
PID=""

cd "$ROOT_DIR"

cleanup() {
  if [[ -n "$PID" ]] && kill -0 "$PID" >/dev/null 2>&1; then
    kill "$PID" >/dev/null 2>&1 || true
    wait "$PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

fingerprint() {
  find Monkin -type f -print | sort | while IFS= read -r file; do
    stat -f '%m %z %N' "$file"
  done
  stat -f '%m %z %N' project.yml
}

stop_running_client() {
  osascript -e 'tell application id "com.banyudu.monkin" to quit' >/dev/null 2>&1 || true
  pkill -f "$DEV_APP/Contents/MacOS/Monkin" >/dev/null 2>&1 || true
}

build_and_restart() {
  printf '\n[%s] Building debug Monkin...\n' "$(date '+%H:%M:%S')"
  xcodegen generate >/dev/null
  if ! xcodebuild -project "$PROJECT" -scheme Monkin -configuration Debug \
      -derivedDataPath "$ROOT_DIR/.build/debug" build \
      CODE_SIGNING_ALLOWED=NO >/dev/null; then
    printf '[%s] Build failed; keeping previous app state.\n' "$(date '+%H:%M:%S')"
    return
  fi

  rm -rf "$DEV_APP"
  mkdir -p "$(dirname "$DEV_APP")"
  ditto "$ROOT_DIR/.build/debug/Build/Products/Debug/Monkin.app" "$DEV_APP"
  local identity="${MONKIN_SIGNING_IDENTITY:-}"
  if [[ -z "$identity" ]]; then
    identity="$(security find-identity -v -p codesigning 2>/dev/null \
      | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' | head -n 1)"
  fi
  if [[ -n "$identity" ]]; then
    codesign --force --sign "$identity" "$DEV_APP" >/dev/null
    printf '[%s] Signed dev app with: %s\n' "$(date '+%H:%M:%S')" "$identity"
  else
    codesign --force --sign - "$DEV_APP" >/dev/null
    printf '[%s] WARNING: no signing identity; using ad-hoc signing.\n' "$(date '+%H:%M:%S')"
  fi

  stop_running_client
  open --new "$DEV_APP"
}

build_and_restart
last_fingerprint="$(fingerprint)"
printf '\nWatching Monkin/ and project.yml. Press Ctrl-C to stop.\n'

while true; do
  sleep 1
  current_fingerprint="$(fingerprint)"
  if [[ "$current_fingerprint" != "$last_fingerprint" ]]; then
    last_fingerprint="$current_fingerprint"
    build_and_restart
  fi
done
