#!/usr/bin/env bash

set -euo pipefail

git pull
update_msg=$(nix flake update 2>&1 | grep -v 'warning:')
just rebuild
git add .

read -p "Commit and push changes? [yN]? " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

git commit -S -m "nix flake update: $(TZ=UTC date '+%Y-%m-%d %H:%M:%S %Z')

$update_msg"
echo "$update_msg"
git push
