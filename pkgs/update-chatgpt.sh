#!/usr/bin/env bash
# Update the version, URL and hash in pkgs/chatgpt.nix.
# Usage: ./update-chatgpt.sh [VERSION]
#   VERSION  optional, e.g. 26.818.41705.
#            defaults to the latest version from the OpenAI deb repository.
#
# Version, URL, hash and the bundled-plugins cache suffix all come from the
# repo's Packages index, so no deb download is needed.

set -euo pipefail

BASE="https://persistent.oaistatic.com/codex-app-prod/linux/deb"
INDEX="${BASE}/dists/stable/main/binary-amd64/Packages"
PACKAGE_NIX="$(dirname "$0")/chatgpt.nix"

INDEX_BODY=$(curl -fsSL "$INDEX")

if [[ $# -ge 1 ]]; then
  VERSION="$1"
else
  echo "fetching latest version from the deb index..."
  VERSION=$(awk '$1 == "Version:" { print $2 }' <<<"$INDEX_BODY" | sort -V | tail -n1)
fi

echo "version: ${VERSION}"
SHA256_HEX=$(awk -v v="$VERSION" '
  $1 == "Version:"  { want = ($2 == v) }
  want && $1 == "SHA256:" { print $2; exit }
' <<<"$INDEX_BODY")
if [[ -z "$SHA256_HEX" ]]; then
  echo "error: version ${VERSION} not found in the deb index" >&2
  exit 1
fi
echo "sha256: ${SHA256_HEX}"

# nix hash format: sha256-<base64 of the 32-byte digest, standard padding>
HASH="sha256-$(printf '%b' "$(printf '%s' "${SHA256_HEX}" | sed 's/../\\x&/g')" | openssl base64)"
echo "hash: ${HASH}"

CURRENT_VERSION=$(grep 'version = ' "$PACKAGE_NIX" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')
if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "version unchanged (${VERSION}), updating hashes only"
fi

# the version appears in the version attr, the url, and the plugin cache suffix
sed -i "s|${CURRENT_VERSION}|${VERSION}|g" "$PACKAGE_NIX"
sed -i \
  "s|hash = \"sha256-[^\"]*\";|hash = \"${HASH}\";|" \
  "$PACKAGE_NIX"

echo "updated ${PACKAGE_NIX} to ${VERSION}"
