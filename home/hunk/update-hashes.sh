#!/usr/bin/env bash
# Update the version and hashes in home/hunk/package.nix.
# Usage: ./update-hashes.sh [VERSION]
#   VERSION  optional, e.g. 0.10.0 (without the leading 'v').
#            defaults to the latest release from GitHub.

set -euo pipefail

DIR="$(dirname "$0")"
exec bash "$DIR/../lib/update-github-hashes.sh" \
  modem-dev/hunk hunkdiff "$DIR/package.nix" "$@"
