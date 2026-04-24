{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  claude-litellm = pkgs.writeShellScriptBin "claude-litellm" ''
    set -euo pipefail

    base="''${LITELLM_BASE_URL:-''${ANTHROPIC_BASE_URL:-http://127.0.0.1:4000}}"
    token="''${LITELLM_API_KEY:-''${ANTHROPIC_AUTH_TOKEN:-sk-noauth}}"

    models_json=$(${pkgs.curl}/bin/curl -s -f -m 5 -H "Authorization: Bearer $token" "$base/v1/models") || {
      echo "error: litellm not reachable at $base" >&2
      exit 1
    }

    model=$(echo "$models_json" |
      ${pkgs.jq}/bin/jq -r '.data[].id' |
      ${pkgs.fzf}/bin/fzf --prompt='litellm model> ' --height=40%)

    [[ -z "$model" ]] && exit 1

    export ANTHROPIC_BASE_URL="$base"
    export ANTHROPIC_AUTH_TOKEN="$token"
    export ANTHROPIC_DEFAULT_SONNET_MODEL="$model"
    export ANTHROPIC_DEFAULT_HAIKU_MODEL="$model"
    export ANTHROPIC_DEFAULT_OPUS_MODEL="$model"
    export CLAUDE_CODE_SUBAGENT_MODEL="$model"

    exec ${unstable.claude-code}/bin/claude --model "$model" "$@"
  '';
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [
      unstable.claude-code
      claude-litellm
    ];

    home.file.".claude/statusline-command.sh" = {
      source = ./claude/statusline-command.sh;
      executable = true;
    };

    home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      public="${./claude/settings.json}"
      private="$HOME/.claude/settings.private.json"
      out="$HOME/.claude/settings.json"

      run mkdir -p "$HOME/.claude"

      tmp=$(mktemp)
      if [ -f "$private" ]; then
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$public" "$private" > "$tmp"
      else
        cp "$public" "$tmp"
      fi
      run chmod u+w "$HOME/.claude" 2>/dev/null || true
      run chmod u+w "$out" 2>/dev/null || true
      run mv "$tmp" "$out"
    '';
  };
}
