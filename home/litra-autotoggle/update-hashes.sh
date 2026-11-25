#!/usr/bin/env bash
# Update the version and hash in home/litra-autotoggle/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 1.4.1 (without the leading 'v'); defaults to latest.

set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [VERSION]" >&2
  exit 1
fi

DIR="$(dirname "$0")"
PACKAGE_NIX="$DIR/package.nix"

# shellcheck source=home/lib/update-common.sh
source "$DIR/../lib/update-common.sh"

github_release timrogers/litra-autotoggle v "${1:-}"
skip_if_current "$PACKAGE_NIX" "$VERSION"

ASSET="litra-autotoggle_v${VERSION}_darwin-aarch64"
HASH=$(release_sri "$ASSET" "https://github.com/timrogers/litra-autotoggle/releases/download/v${VERSION}/${ASSET}")

set_version "$PACKAGE_NIX" "$VERSION"

sed -i \
  '/darwin-aarch64";/{n; s|hash = "[^"]*";|hash = "'"${HASH}"'";|}' \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
