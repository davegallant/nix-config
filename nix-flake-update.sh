#!/usr/bin/env bash

set -euo pipefail

git pull
update_msg=$(nix flake update 2>&1 | grep -v 'warning:')
make
git add .
git commit -S -m "nix flake update: $(TZ=UTC date '+%Y-%m-%d %H:%M:%S %Z')

$update_msg"
echo "$update_msg"
git push
