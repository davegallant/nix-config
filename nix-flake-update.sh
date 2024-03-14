#!/usr/bin/env bash

set -euo pipefail

arch=$(uname -s)

git pull
update_msg=$(nix flake update 2>&1 | grep -v 'warning:')
if [[ $arch == "Linux" ]]; then
  just build-linux
elif [[ $arch == "Darwin" ]]; then
  just build-mac
else
  echo "Unsupported OS: $arch"
  exit 1
fi
git add .
git commit -S -m "nix flake update: $(TZ=UTC date '+%Y-%m-%d %H:%M:%S %Z')

$update_msg"
echo "$update_msg"
git push
