#!/usr/bin/env bash
# Update the version and hash in home/codex/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 0.145.0 (without the leading 'rust-v').
#            defaults to the latest release from GitHub.
#
# codex needs its own updater (not lib/update-github-hashes.sh) because release
# tags carry a "rust-v" prefix and the darwin asset is named
# codex-aarch64-apple-darwin.tar.gz. kratos (aarch64-darwin) is the only
# consumer, so only that hash is tracked.

set -euo pipefail

REPO="openai/codex"
DIR="$(dirname "$0")"
PACKAGE_NIX="$DIR/package.nix"
VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "fetching latest release from github.com/${REPO}..."
  VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"rust-v\?\([^"]*\)".*/\1/')
fi

echo "version: ${VERSION}"

URL="https://github.com/${REPO}/releases/download/rust-v${VERSION}/codex-aarch64-apple-darwin.tar.gz"
echo "  fetching ${URL##*/}..."
HASH="sha256-$(curl -fsSL "$URL" | openssl dgst -sha256 -binary | openssl base64)"
echo "  hash: ${HASH}"

CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')

if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "version unchanged (${VERSION}), updating hash only"
else
  echo "updating version: ${CURRENT_VERSION} -> ${VERSION}"
  sed -i "s|version = \"${CURRENT_VERSION}\";|version = \"${VERSION}\";|" "$PACKAGE_NIX"
fi

sed -i \
  "/codex-aarch64-apple-darwin\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH}\";|}" \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
