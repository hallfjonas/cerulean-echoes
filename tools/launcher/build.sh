#!/bin/bash
# Compiles tools/launcher/app/main.swift into "Cerulean Echoes.app" in the repo folder: a small native app that shows
# the player in its own window (WKWebView) and runs launch.sh. The app is committed, so a fresh clone needs no build:
# run this only after changing app/ (npm run launcher in tools/), then commit the app. macOS only; needs the Xcode
# command line tools (swiftc). The source's hash goes into Info.plist (CESourceHash): the test checks it is current.
# The icon: app/AppIcon.icns, drawn from app/icon.svg (PNG sizes 16-1024 in one .icns); redraw it only when the SVG changes.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
app="${1:-$repo/Cerulean Echoes.app}"
command -v swiftc >/dev/null 2>&1 || { echo "swiftc is missing: run  xcode-select --install  once, then again" >&2; exit 1; }
tmp="$(mktemp -d)"
swiftc -O -o "$tmp/CeruleanEchoes" "$here/app/main.swift" -framework Cocoa -framework WebKit
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
mv "$tmp/CeruleanEchoes" "$app/Contents/MacOS/CeruleanEchoes"
cp "$here/app/Info.plist" "$app/Contents/Info.plist"
cp "$here/app/AppIcon.icns" "$app/Contents/Resources/AppIcon.icns"
printf 'APPL????' > "$app/Contents/PkgInfo"
/usr/libexec/PlistBuddy -c "Add :CESourceHash string $(shasum -a 256 "$here/app/main.swift" | cut -d' ' -f1)" "$app/Contents/Info.plist"
rm -rf "$tmp"
touch "$app"   # Finder and Dock pick up a changed icon
codesign --force --sign - "$app"
echo "built $app"
