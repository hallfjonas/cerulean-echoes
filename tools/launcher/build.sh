#!/bin/bash
# Compiles tools/launcher/launcher.applescript into "Cerulean Echoes.app" in the repo folder (a stay-open AppleScript
# applet). The app is committed, so a fresh clone needs no build: run this only after changing launcher.applescript
# (npm run launcher in tools/), then commit the app. macOS only.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
app="${1:-$repo/Cerulean Echoes.app}"
rm -rf "$app"
osacompile -s -o "$app" "$here/launcher.applescript"
plist="$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier org.cerulean-echoes.launcher' "$plist" 2>/dev/null ||
  /usr/libexec/PlistBuddy -c 'Add :CFBundleIdentifier string org.cerulean-echoes.launcher' "$plist"
# the Info.plist changed: seal the bundle again (ad hoc, as osacompile does)
codesign --force --sign - "$app"
echo "built $app"
