#!/usr/bin/env bash
set -euo pipefail

if [ $# -gt 1 ]; then
  channel=$1
  shift
else
  channel=nixpkgs
fi
query="$*"
nix search "$channel" "$query" 2>/dev/null \
  | grep "^\*" \
  | sed "s/legacyPackages\.[^.]*\.//" \
  | grep -E "^\* [^[:space:]]*${query}"
