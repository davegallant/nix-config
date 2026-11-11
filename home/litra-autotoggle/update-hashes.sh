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
VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  VERSION=$(latest_github_tag timrogers/litra-autotoggle v)
fi

echo "version: ${VERSION}"

URL="https://github.com/timrogers/litra-autotoggle/releases/download/v${VERSION}/litra-autotoggle_v${VERSION}_darwin-aarch64"
HASH=$(sri "$URL")

set_version "$PACKAGE_NIX" "$VERSION"

sed -i \
  '/darwin-aarch64";/{n; s|hash = "[^"]*";|hash = "'"${HASH}"'";|}' \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX}"
