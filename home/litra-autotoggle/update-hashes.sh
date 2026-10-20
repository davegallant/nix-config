#!/usr/bin/env bash
# Update the version and hash in home/litra-autotoggle/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 1.4.1 (without the leading 'v'); defaults to latest.

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [VERSION]" >&2
  exit 1
fi

PACKAGE_NIX="$(dirname "$0")/package.nix"
VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "fetching latest release from github.com/timrogers/litra-autotoggle..."
  VERSION=$(curl -fsSL "https://api.github.com/repos/timrogers/litra-autotoggle/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')
fi

echo "version: ${VERSION}"

URL="https://github.com/timrogers/litra-autotoggle/releases/download/v${VERSION}/litra-autotoggle_v${VERSION}_darwin-aarch64"
echo "  fetching ${URL##*/}..." >&2
HASH="sha256-$(curl -fsSL "$URL" | openssl dgst -sha256 -binary | openssl base64)"

CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')
if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "version unchanged (${VERSION}), updating hash only"
else
  echo "updating version: ${CURRENT_VERSION} -> ${VERSION}"
  sed -i "s|version = \"${CURRENT_VERSION}\";|version = \"${VERSION}\";|" "$PACKAGE_NIX"
fi

sed -i \
  '/darwin-aarch64";/{n; s|hash = "[^"]*";|hash = "'"${HASH}"'";|}' \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
