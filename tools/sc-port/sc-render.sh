#!/bin/bash
# Render the SuperCollider version of a track offline: sc-render.sh <scenario.json> <out-prefix> [stem,stem]
# Track: CE_TRACK=<folder>/<name> (default 009-house/009-house, see batch.py)
# sclang: SCLANG in the environment, else the macOS app, else sclang on the PATH. Log: <out-prefix>.log
here="$(cd "$(dirname "$0")" && pwd)"
root="$here/../.."
SCLANG="${SCLANG:-/Applications/SuperCollider.app/Contents/MacOS/sclang}"
[ -x "$SCLANG" ] || SCLANG="$(command -v sclang)"
TO=""; command -v timeout >/dev/null && TO="timeout 180"   # macOS has no timeout unless coreutils are installed
$TO "$SCLANG" "$root/sc/tools/render.scd" "$root/sc/tracks/${CE_TRACK:-009-house/009-house}.scd" "$@" > "$2.log" 2>&1
grep -q "^rendered" "$2.log" || { grep -A12 "ERROR" "$2.log" | head -30; echo "RENDER FAILED: $2"; exit 1; }
