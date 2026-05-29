#!/usr/bin/env bash
# Shared helper: update the version and per-arch SRI hashes in a package.nix
# that pulls prebuilt tarballs from a GitHub release.
#
# Usage: update-github-hashes.sh <repo> <asset-prefix> <package.nix> [VERSION]
#   repo          owner/name, e.g. badlogic/pi-mono
#   asset-prefix  release asset basename prefix, e.g. "pi" or "hunkdiff".
#                 Expects assets named:
#                   <prefix>-linux-x64.tar.gz
#                   <prefix>-linux-arm64.tar.gz
#                   <prefix>-darwin-arm64.tar.gz
#   package.nix   path to the file to rewrite (hashes sit on the line after
#                 each asset URL)
#   VERSION       optional, without the leading 'v' (e.g. 0.73.0).
#                 Defaults to the latest GitHub release.

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <repo> <asset-prefix> <package.nix> [VERSION]" >&2
  exit 1
fi

REPO="$1"
PREFIX="$2"
PACKAGE_NIX="$3"
VERSION="${4:-}"
BASE_URL="https://github.com/${REPO}/releases/download"

# resolve version
if [[ -z "$VERSION" ]]; then
  echo "fetching latest release from github.com/${REPO}..."
  VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')
fi

echo "version: ${VERSION}"

sri() {
  local url="$1"
  echo "  fetching ${url##*/}..." >&2
  local hash
  hash=$(curl -fsSL "$url" | openssl dgst -sha256 -binary | openssl base64)
  echo "sha256-${hash}"
}

HASH_X86_LINUX=$(sri  "${BASE_URL}/v${VERSION}/${PREFIX}-linux-x64.tar.gz")
HASH_ARM_LINUX=$(sri  "${BASE_URL}/v${VERSION}/${PREFIX}-linux-arm64.tar.gz")
HASH_ARM_DARWIN=$(sri "${BASE_URL}/v${VERSION}/${PREFIX}-darwin-arm64.tar.gz")

echo ""
echo "hashes:"
echo "  x86_64-linux:   ${HASH_X86_LINUX}"
echo "  aarch64-linux:  ${HASH_ARM_LINUX}"
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
sed -i \
  "/${PREFIX}-linux-x64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_X86_LINUX}\";|}" \
  "$PACKAGE_NIX"

sed -i \
  "/${PREFIX}-linux-arm64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_ARM_LINUX}\";|}" \
  "$PACKAGE_NIX"

sed -i \
  "/${PREFIX}-darwin-arm64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_ARM_DARWIN}\";|}" \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
