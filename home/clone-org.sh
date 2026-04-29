#!/usr/bin/env bash
set -euo pipefail

ORG="${1:?Usage: clone-org <org> <target-dir>}"
TARGET_DIR="${2:?Usage: clone-org <org> <target-dir>}"

mkdir -p "$TARGET_DIR"

echo "Fetching repos for org: $ORG"

gh repo list "$ORG" --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' | \
  while read -r repo; do
    name="${repo##*/}"
    dest="$TARGET_DIR/$name"
    if [ -d "$dest" ]; then
      echo "  skip  $repo (already exists)"
    else
      echo "  clone $repo → $dest"
      gh repo clone "$repo" "$dest"
    fi
  done
