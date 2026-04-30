{
  config,
  lib,
  pkgs,
  ...
}:
let
  claude-code = pkgs.callPackage ./claude/package.nix { };
  claude-litellm = pkgs.writeShellScriptBin "claude-litellm" (
    builtins.readFile ./claude/claude-litellm.sh
  );
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [
      claude-code
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
