#!/bin/bash
set -euo pipefail

# FeedlessSafari — Rebuild from upstream Feedless
# Clones the latest Feedless Chrome extension, builds it,
# converts to Safari, and regenerates the Xcode project.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "==> Cloning upstream Feedless..."
git clone --depth 1 https://github.com/ZMensRain/Feedless.git "$TEMP_DIR/feedless" 2>/dev/null || {
  echo "ERROR: Could not clone Feedless. Check the repo URL."
  exit 1
}

echo "==> Installing dependencies..."
cd "$TEMP_DIR/feedless"
npm install

echo "==> Building WXT extension..."
npm run build

echo "==> Converting to Safari..."
# safari-web-extension-converter outputs to /tmp/feedless-convert by default
# Clean any previous conversion first
rm -rf /tmp/feedless-convert
xcrun safari-web-extension-converter \
  --app-name "FeedlessSafari" \
  --bundle-identifier "com.mattwagner.feedless-safari" \
  --project-location /tmp/feedless-convert \
  --no-open \
  dist/

echo "==> Syncing extension resources..."
rsync -a --delete \
  /tmp/feedless-convert/FeedlessSafari/Shared\ \(Extension\)/Resources/ \
  "$PROJECT_DIR/Shared (Extension)/Resources/"

echo "==> Re-applying custom overlay manifest entries..."
python3 "$SCRIPT_DIR/patch-manifest.py"

echo "==> Regenerating Xcode project..."
cd "$PROJECT_DIR"
xcodegen generate

echo "==> Done!"
echo "Open FeedlessSafari.xcodeproj in Xcode and verify the build."