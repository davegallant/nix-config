#!/usr/bin/env bash

set -euo pipefail

if ! git diff-index --quiet HEAD --; then
  git stash push -m "Auto-stash via update-flake.sh on $(date)"
fi

git pull
update_msg=$(nix flake update 2>&1 | grep -v 'warning:')
old_system=$(readlink -f /run/current-system)
just rebuild
new_system=$(readlink -f /run/current-system)
nvd_diff=$(nvd diff "$old_system" "$new_system" 2>/dev/null || true)
git add .

read -p "Commit and push changes? [yN]? " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

commit_msg="nix flake update: $(TZ=UTC date '+%Y-%m-%d %H:%M:%S %Z')

$update_msg"

if [[ -n "$nvd_diff" ]]; then
  commit_msg="$commit_msg

Package changes:
$nvd_diff"
fi

git commit -S -m "$commit_msg"
echo "$update_msg"
git push
