#!/usr/bin/env bash
# Update the mattpocock/skills rev and hash in home/claude.nix.
# Usage: ./update-mattpocock-skills-hash.sh <REV>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <git-rev>" >&2
  exit 1
fi

REV="$1"
CLAUDE_NIX="$(dirname "$0")/../../home/claude.nix"

echo "fetching hash for mattpocock/skills@${REV}..."
HASH=$(nix-prefetch-url --unpack --type sha256 \
  "https://github.com/mattpocock/skills/archive/${REV}.tar.gz" 2>/dev/null)
SRI=$(nix --extra-experimental-features "nix-command" hash convert \
  --hash-algo sha256 --to sri "$HASH")

echo "  rev:  ${REV}"
echo "  hash: ${SRI}"

OLD_REV=$(grep 'rev = ".*"; # mattpocock/skills' "$CLAUDE_NIX" \
  | sed 's/.*rev = "\([^"]*\)".*/\1/')

sed -i \
  "s|rev = \"${OLD_REV}\"; # mattpocock/skills|rev = \"${REV}\"; # mattpocock/skills|" \
  "$CLAUDE_NIX"

sed -i \
  "/rev = \"${REV}\"; # mattpocock\/skills/{n; s|hash = \"[^\"]*\";|hash = \"${SRI}\";|}" \
  "$CLAUDE_NIX"

echo "updated ${CLAUDE_NIX}"
