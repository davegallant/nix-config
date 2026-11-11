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

# shellcheck source=home/lib/update-common.sh
source "$DIR/../lib/update-common.sh"

if [[ -z "$VERSION" ]]; then
  VERSION=$(latest_github_tag "$REPO" rust-v)
fi

echo "version: ${VERSION}"

set_version "$PACKAGE_NIX" "$VERSION"

declare -A ASSETS=(
  [codex-aarch64-apple-darwin.tar.gz]=1
  [codex-x86_64-unknown-linux-musl.tar.gz]=1
  [codex-code-mode-host-aarch64-apple-darwin.tar.gz]=1
  [codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz]=1
)

for asset in "${!ASSETS[@]}"; do
  URL="https://github.com/${REPO}/releases/download/rust-v${VERSION}/${asset}"
  HASH=$(sri "$URL")
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
