#!/usr/bin/env bash
# Update the version and hash in home/codex/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 0.145.0 (without the leading 'rust-v').
#            defaults to the latest release from GitHub.
#
# codex needs its own updater (not lib/update-github-hashes.sh) because release
# tags carry a "rust-v" prefix and assets include the CLI and code-mode host.
# Tracks both consumers: aarch64-darwin (kratos, helios) and x86_64-linux
# (hephaestus).

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

CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')

if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "version unchanged (${VERSION}), updating hashes only"
else
  echo "updating version: ${CURRENT_VERSION} -> ${VERSION}"
  sed -i "s|version = \"${CURRENT_VERSION}\";|version = \"${VERSION}\";|" "$PACKAGE_NIX"
fi

declare -A ASSETS=(
  [codex-aarch64-apple-darwin.tar.gz]=1
  [codex-x86_64-unknown-linux-musl.tar.gz]=1
  [codex-code-mode-host-aarch64-apple-darwin.tar.gz]=1
  [codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz]=1
)

for asset in "${!ASSETS[@]}"; do
  URL="https://github.com/${REPO}/releases/download/rust-v${VERSION}/${asset}"
  echo "  fetching ${asset}..."
  HASH="sha256-$(curl -fsSL "$URL" | openssl dgst -sha256 -binary | openssl base64)"
  echo "  hash: ${HASH}"
  if [[ "$asset" == codex-code-mode-host-* ]]; then
    sed -i \
      "/${asset//./\\.}\";/{n; s|codeModeHostHash = \"[^\"]*\";|codeModeHostHash = \"${HASH}\";|}" \
      "$PACKAGE_NIX"
  else
    sed -i \
      "/${asset//./\\.}\";/{n; s|hash = \"[^\"]*\";|hash = \"${HASH}\";|}" \
      "$PACKAGE_NIX"
  fi
done

echo "updated ${PACKAGE_NIX}"
