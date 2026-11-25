#!/usr/bin/env bash
# Shared helper: update the version and per-arch SRI hashes in a package.nix
# that pulls prebuilt tarballs from a GitHub release.
#
# Usage: update-github-hashes.sh <repo> <asset-prefix> <package.nix> [VERSION]
#   repo          owner/name, e.g. badlogic/pi-mono
#   asset-prefix  release asset basename prefix, e.g. "pi" or "hunkdiff".
#                 Expects assets named:
#                   <prefix>-linux-x64.tar.gz
#                   <prefix>-darwin-arm64.tar.gz
#   package.nix   path to the file to rewrite (hashes sit on the line after
#                 each asset URL)
#   VERSION       optional, without the leading 'v' (e.g. 0.73.0).
#                 Defaults to the latest GitHub release.

set -euo pipefail

# shellcheck source=home/lib/update-common.sh
source "$(dirname "$0")/update-common.sh"

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <repo> <asset-prefix> <package.nix> [VERSION]" >&2
  exit 1
fi

REPO="$1"
PREFIX="$2"
PACKAGE_NIX="$3"
BASE_URL="https://github.com/${REPO}/releases/download"

github_release "$REPO" v "${4:-}"
skip_if_current "$PACKAGE_NIX" "$VERSION"

LINUX="${PREFIX}-linux-x64.tar.gz"
DARWIN="${PREFIX}-darwin-arm64.tar.gz"
HASH_X86_LINUX=$(release_sri "$LINUX" "${BASE_URL}/v${VERSION}/${LINUX}")
HASH_ARM_DARWIN=$(release_sri "$DARWIN" "${BASE_URL}/v${VERSION}/${DARWIN}")

echo "hashes:"
echo "  x86_64-linux:   ${HASH_X86_LINUX}"
echo "  aarch64-darwin: ${HASH_ARM_DARWIN}"

set_version "$PACKAGE_NIX" "$VERSION"

# update hashes by matching the url pattern adjacent to each hash line
sed -i \
  "/${PREFIX}-linux-x64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_X86_LINUX}\";|}" \
  "$PACKAGE_NIX"

sed -i \
  "/${PREFIX}-darwin-arm64\.tar\.gz/{n; s|hash = \"[^\"]*\";|hash = \"${HASH_ARM_DARWIN}\";|}" \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
