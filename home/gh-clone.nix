{ ... }:

{
  home.file.".local/bin/gh-clone" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      usage() {
        echo "Usage: gh-clone [--no-cache] <org>"
        exit 1
      }

      NO_CACHE=false

      while [[ $# -gt 0 ]]; do
        case "$1" in
          --no-cache) NO_CACHE=true; shift ;;
          -*) usage ;;
          *) break ;;
        esac
      done

      ORG="''${1:?$(usage)}"

      BASE_DIR="$HOME/src/github.com/''${ORG}"
      CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/gh-clone"
      CACHE_FILE="$CACHE_DIR/''${ORG}.txt"
      CACHE_TTL=604800 # seconds

      mkdir -p "$BASE_DIR" "$CACHE_DIR"

      now=$(date +%s)

      if [ -f "$CACHE_FILE" ]; then
        cache_mtime=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE")
        cache_age=$(( now - cache_mtime ))
      else
        cache_age=$CACHE_TTL
      fi

      if [ "$NO_CACHE" = true ] || [ "$cache_age" -ge "$CACHE_TTL" ]; then
        echo "Fetching repos for org: $ORG..." >&2
        gh repo list "$ORG" --limit 10000 --json nameWithOwner -q '.[].nameWithOwner' > "$CACHE_FILE"
      else
        echo "Using cached repo list (expires in $(( CACHE_TTL - cache_age ))s)..." >&2
      fi

      selected=$(fzf --multi --prompt="Select repo to clone > " < "$CACHE_FILE")

      if [ -z "$selected" ]; then
        echo "Nothing selected, exiting."
        exit 0
      fi

      echo "$selected" | while read -r repo; do
        name="''${repo##*/}"
        dest="$BASE_DIR/$name"
        if [ -d "$dest" ]; then
          echo "  skip  $repo (already exists)"
        else
          echo "  clone $repo → $dest"
          gh repo clone "$repo" "$dest"
        fi
      done
    '';
  };
}
