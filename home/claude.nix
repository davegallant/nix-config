{ lib, pkgs, unstable, ... }:
let
  claude-model-picker = pkgs.writeShellScriptBin "claude-model-picker" ''
    set -euo pipefail

    token=$ANTHROPIC_AUTH_TOKEN
    base=$ANTHROPIC_BASE_URL

    model=$(${pkgs.curl}/bin/curl -s -H "Authorization: Bearer $token" "$base/models" |
      ${pkgs.jq}/bin/jq -r '.data[].id' |
      ${pkgs.fzf}/bin/fzf --prompt='model> ' --height=40%)

    [[ -z "$model" ]] && exit 1

    exec ${unstable.claude-code}/bin/claude --model "$model" "$@"
  '';
in
{
  home.packages = [
    unstable.claude-code
    claude-model-picker
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

    if [ -f "$private" ]; then
      run ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$public" "$private" > "$out.tmp"
    else
      run cp "$public" "$out.tmp"
    fi
    run mv "$out.tmp" "$out"
  '';
}
