#!/usr/bin/env bash
# Update the version and hashes in home/claude/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 2.1.123 (without the leading 'v').
#            defaults to the latest release from GitHub.

set -euo pipefail

PACKAGE_NIX="$(dirname "$0")/package.nix"
REPO="anthropics/claude-code"
BASE_URL="https://github.com/${REPO}/releases/download"

# resolve version
if [[ $# -ge 1 ]]; then
  VERSION="$1"
else
  echo "fetching latest release from github.com/${REPO}..."
  TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')
  VERSION="$TAG"
fi

echo "version: ${VERSION}"

sri() {
  local url="$1"
  echo "  fetching ${url##*/}..." >&2
  local hash
  hash=$(curl -fsSL "$url" | openssl dgst -sha256 -binary | openssl base64)
  echo "sha256-${hash}"
}

HASH_X86_LINUX=$(sri  "${BASE_URL}/v${VERSION}/claude-linux-x64.tar.gz")
HASH_ARM_LINUX=$(sri  "${BASE_URL}/v${VERSION}/claude-linux-arm64.tar.gz")
HASH_ARM_DARWIN=$(sri "${BASE_URL}/v${VERSION}/claude-darwin-arm64.tar.gz")

echo ""
echo "hashes:"
echo "  x86_64-linux:  ${HASH_X86_LINUX}"
echo "  aarch64-linux: ${HASH_ARM_LINUX}"
echo "  aarch64-darwin: ${HASH_ARM_DARWIN}"
echo ""

# current version in the file
CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')

if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "version unchanged (${VERSION}), updating hashes only"
else
  echo "updating version: ${CURRENT_VERSION} -> ${VERSION}"
  sed -i "s|version = \"${CURRENT_VERSION}\";|version = \"${VERSION}\";|" "$PACKAGE_NIX"
fi

# update hashes by matching the url pattern adjacent to each hash line
# strategy: replace the hash on the line immediately following the relevant url
sed -i \
  "/claude-linux-x64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_X86_LINUX}\";|}" \
  "$PACKAGE_NIX"

sed -i \
  "/claude-linux-arm64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_ARM_LINUX}\";|}" \
  "$PACKAGE_NIX"

sed -i \
  "/claude-darwin-arm64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_ARM_DARWIN}\";|}" \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
