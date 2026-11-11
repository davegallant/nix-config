#!/usr/bin/env bash
# Update the version and hashes in home/claude/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 2.1.126 (without the leading 'v').
#            defaults to the latest from npm.

set -euo pipefail

DIR="$(dirname "$0")"
PACKAGE_NIX="$DIR/package.nix"

# shellcheck source=home/lib/update-common.sh
source "$DIR/../lib/update-common.sh"
NPM_REGISTRY="https://registry.npmjs.org"

# resolve version
if [[ $# -ge 1 ]]; then
  VERSION="$1"
else
  echo "fetching latest version from npm..."
  VERSION=$(curl -fsSL "${NPM_REGISTRY}/@anthropic-ai/claude-code/latest" \
    | grep '"version"' | sed 's/.*"version": *"\([^"]*\)".*/\1/')
fi

echo "version: ${VERSION}"

npm_integrity() {
  local pkg="$1"
  echo "  fetching ${pkg}@${VERSION}..." >&2
  curl -fsSL "${NPM_REGISTRY}/@anthropic-ai/${pkg}/${VERSION}" \
    | grep '"integrity"' | sed 's/.*"integrity": *"\([^"]*\)".*/\1/'
}

HASH_X86_LINUX=$(npm_integrity "claude-code-linux-x64")
HASH_ARM_DARWIN=$(npm_integrity "claude-code-darwin-arm64")

echo ""
echo "hashes:"
echo "  x86_64-linux:  ${HASH_X86_LINUX}"
echo "  aarch64-darwin: ${HASH_ARM_DARWIN}"
echo ""

set_version "$PACKAGE_NIX" "$VERSION"

sed -i \
  "/claude-code-linux-x64-/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_X86_LINUX}\";|}" \
  "$PACKAGE_NIX"

sed -i \
  "/claude-code-darwin-arm64-/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_ARM_DARWIN}\";|}" \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
