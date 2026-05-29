#!/usr/bin/env bash
# Update the version and hashes in home/pi/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 0.73.0 (without the leading 'v').
#            defaults to the latest release from GitHub.

set -euo pipefail

DIR="$(dirname "$0")"
exec bash "$DIR/../lib/update-github-hashes.sh" \
  badlogic/pi-mono pi "$DIR/package.nix" "$@"
