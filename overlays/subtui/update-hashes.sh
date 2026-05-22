#!/usr/bin/env bash
# Update version and hashes in overlays/subtui/default.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 2.14.2 (without the leading 'v').
#            Defaults to the latest release from GitHub.

set -euo pipefail

OVERLAY_NIX="$(dirname "$0")/default.nix"
OWNER="MattiaPun"
REPO="SubTUI"

if [[ $# -ge 1 ]]; then
  VERSION="$1"
else
  echo "fetching latest release from github.com/${OWNER}/${REPO}..."
  VERSION=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')
fi

echo "version: ${VERSION}"

# Get source hash
echo "fetching source hash..."
SOURCE_HASH=$(nix run nixpkgs#nix-prefetch-github -- \
  --json "${OWNER}" "${REPO}" --rev "v${VERSION}" 2>/dev/null \
  | grep '"hash"' | sed 's/.*"hash": *"\([^"]*\)".*/\1/')
echo "hash: ${SOURCE_HASH}"

# Compute vendorHash by cloning and running go mod vendor
echo "computing vendorHash..."
TMPDIR_PATH=$(mktemp -d)
trap 'rm -rf "${TMPDIR_PATH}"' EXIT

git clone --quiet --depth 1 --branch "v${VERSION}" \
  "https://github.com/${OWNER}/${REPO}.git" "${TMPDIR_PATH}/src"
(cd "${TMPDIR_PATH}/src" && go mod vendor)
VENDOR_HASH=$(nix hash path "${TMPDIR_PATH}/src/vendor")
echo "vendorHash: ${VENDOR_HASH}"

# Update the Nix file
CURRENT_VERSION=$(grep 'version = ' "${OVERLAY_NIX}" | head -1 | sed 's/.*version = "\([^"]*\)".*/\1/')
if [[ "${CURRENT_VERSION}" != "${VERSION}" ]]; then
  echo "updating version: ${CURRENT_VERSION} -> ${VERSION}"
  sed -i "s|version = \"${CURRENT_VERSION}\";|version = \"${VERSION}\";|" "${OVERLAY_NIX}"
fi
sed -i "s|rev = \"v[^\"]*\";|rev = \"v${VERSION}\";|" "${OVERLAY_NIX}"
sed -i "s|hash = \"[^\"]*\";|hash = \"${SOURCE_HASH}\";|" "${OVERLAY_NIX}"
sed -i "s|vendorHash = \"[^\"]*\";|vendorHash = \"${VENDOR_HASH}\";|" "${OVERLAY_NIX}"

echo "updated ${OVERLAY_NIX}"
