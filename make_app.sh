#!/usr/bin/env bash
# make_app.sh — Build Reclaim and package it as a double-clickable .app bundle.
# Produces a universal binary (arm64 + x86_64) that runs on any Mac.
# Usage:  ./make_app.sh          (builds + packages in the repo directory)
#         ./make_app.sh --install (also copies to /Applications)
set -euo pipefail

# ── Paths ────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY_NAME="Reclaim"
APP_NAME="${BINARY_NAME}.app"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME"
INSTALL_FLAG="${1:-}"

ARM_BIN="$SCRIPT_DIR/.build/arm64-apple-macosx/release/$BINARY_NAME"
X86_BIN="$SCRIPT_DIR/.build/x86_64-apple-macosx/release/$BINARY_NAME"

# ── 1. Build both architectures ──────────────────────────────────────────────
echo "🔨  Building $BINARY_NAME for arm64…"
cd "$SCRIPT_DIR"
swift build -c release --arch arm64
echo "✔   arm64 done."

echo "🔨  Building $BINARY_NAME for x86_64…"
swift build -c release --arch x86_64
echo "✔   x86_64 done."

# ── 2. Assemble .app structure ───────────────────────────────────────────────
echo "📦  Assembling $APP_NAME…"
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Merge into a universal binary with lipo
echo "🔗  Creating universal binary…"
lipo -create -output "$APP_BUNDLE/Contents/MacOS/$BINARY_NAME" "$ARM_BIN" "$X86_BIN"
echo "✔   Universal binary ready ($(lipo -archs "$APP_BUNDLE/Contents/MacOS/$BINARY_NAME"))."

# Copy Info.plist
if [ ! -f "$SCRIPT_DIR/Info.plist" ]; then
    echo "❌  Info.plist not found at $SCRIPT_DIR/Info.plist"
    exit 1
fi
cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Copy app icon
if [ -f "$SCRIPT_DIR/AppIcon.icns" ]; then
    cp "$SCRIPT_DIR/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    echo "✔   Icon copied."
else
    echo "⚠   AppIcon.icns not found — skipping icon."
fi

# ── 3. Ad-hoc code sign ─────────────────────────────────────────────────────
# "-" means ad-hoc (no Apple Developer account needed).
# This satisfies Gatekeeper for locally-built apps and allows the app
# to use hardened-runtime features without a full Developer ID certificate.
echo "🔏  Ad-hoc signing…"
codesign --force --deep --sign - "$APP_BUNDLE"
echo "✔   Signed."

# ── 4. Done ──────────────────────────────────────────────────────────────────
echo ""
echo "✅  $APP_NAME is ready:"
echo "    $APP_BUNDLE"
echo ""

# ── 5. Optional: install to /Applications ────────────────────────────────────
if [ "$INSTALL_FLAG" = "--install" ]; then
    INSTALL_DEST="/Applications/$APP_NAME"
    echo "📂  Installing to $INSTALL_DEST…"
    rm -rf "$INSTALL_DEST"
    cp -r "$APP_BUNDLE" "$INSTALL_DEST"
    echo "✅  Reclaim is installed. Launch it from Spotlight or /Applications."
else
    echo "To open it right now:"
    echo "    open \"$APP_BUNDLE\""
    echo ""
    echo "To install in /Applications (launch from Spotlight):"
    echo "    ./make_app.sh --install"
fi
