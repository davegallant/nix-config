#!/usr/bin/env bash
# Update the obsidian-git plugin version and hash in home/obsidian.nix.
# Usage: ./obsidian-update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 2.38.2 (without the leading 'v').
#            defaults to the latest release from GitHub.

set -euo pipefail

OBSIDIAN_NIX="$(dirname "$0")/obsidian.nix"
REPO="Vinzent03/obsidian-git"
BASE_URL="https://github.com/${REPO}/releases/download"

# resolve version
if [[ $# -ge 1 ]]; then
  VERSION="$1"
else
  echo "fetching latest release from github.com/${REPO}..."
  VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/')
fi

echo "version: ${VERSION}"

URL="${BASE_URL}/${VERSION}/obsidian-git-${VERSION}.zip"

echo "  fetching ${URL##*/}..."
HASH=$(nix --extra-experimental-features 'nix-command' store prefetch-file \
  --hash-type sha256 --unpack --json "$URL" 2>/dev/null \
  | grep -o '"hash":"[^"]*"' \
  | sed 's/"hash":"//;s/"//')

echo ""
echo "hash: ${HASH}"
echo ""

CURRENT_VERSION=$(grep 'obsidian-git/releases/download/' "$OBSIDIAN_NIX" \
  | sed 's|.*/download/\([^/]*\)/.*|\1|')

if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
  echo "version unchanged (${VERSION}), updating hash only"
else
  echo "updating version: ${CURRENT_VERSION} -> ${VERSION}"
  sed -i \
    "s|obsidian-git/releases/download/${CURRENT_VERSION}/obsidian-git-${CURRENT_VERSION}\.zip|obsidian-git/releases/download/${VERSION}/obsidian-git-${VERSION}.zip|g" \
    "$OBSIDIAN_NIX"
fi

# url line is followed by: name, stripRoot, hash — so skip 3 lines (n;n;n)
sed -i \
  "/obsidian-git-${VERSION}\.zip/{n;n;n; s|hash = \"[^\"]*\";|hash = \"${HASH}\";|}" \
  "$OBSIDIAN_NIX"

echo "updated ${OBSIDIAN_NIX}"
