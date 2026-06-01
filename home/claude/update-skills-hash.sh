#!/usr/bin/env bash
# Update the davegallant/skills rev and hash in home/lib/skills.nix.
# Usage: ./update-skills-hash.sh <REV>
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <git-rev>" >&2
  exit 1
fi

REV="$1"
SKILLS_NIX="$(dirname "$0")/../lib/skills.nix"

echo "fetching hash for davegallant/skills@${REV}..."
HASH=$(nix-prefetch-url --unpack --type sha256 \
  "https://github.com/davegallant/skills/archive/${REV}.tar.gz" 2>/dev/null)
SRI=$(nix --extra-experimental-features "nix-command" hash convert \
  --hash-algo sha256 --to sri "$HASH")

echo "  rev:  ${REV}"
echo "  hash: ${SRI}"

sed -i -E \
  -e "s|rev = \"[^\"]*\"|rev = \"${REV}\"|" \
  -e "s|hash = \"[^\"]*\"|hash = \"${SRI}\"|" \
  "$SKILLS_NIX"

echo "updated ${SKILLS_NIX}"
