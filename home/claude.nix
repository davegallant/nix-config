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
  agent-stuff-skills = pkgs.fetchFromGitHub {
    owner = "mitsuhiko";
    repo = "agent-stuff";
    rev = "ab79f98104bcd3c6a7c5491e609f6d6700a7414d";
    hash = "sha256-Sh79q+6X3cb6ypIDQ34l3SAWSoAQmQLW81mh8dQQOYQ=";
  };
  googleworkspace-cli-skills = pkgs.runCommand "googleworkspace-cli-skills" { } ''
    src=${
      pkgs.fetchFromGitHub {
        owner = "googleworkspace";
        repo = "cli";
        rev = "a3768d0e82ad83cca2da97724e46bea4ff0e6dbd";
        hash = "sha256-YyNIHbyZrLlXYtWxZY8Um19MsnLharmS+nWGWO89fsA=";
      }
    }/skills
    mkdir -p $out
    for skill in \
      gws-shared \
      gws-gmail \
      gws-gmail-read \
      gws-calendar \
      gws-calendar-agenda \
      gws-calendar-insert \
      gws-docs \
      gws-docs-write; do
      cp -r $src/$skill $out/$skill
    done
  '';
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

    home.file.".claude/agents" = {
      source = ./claude/agents;
      recursive = true;
    };

    home.file.".claude/skills" = {
      source = googleworkspace-cli-skills;
      recursive = true;
    };

    home.file.".claude/skills/commit" = {
      source = "${agent-stuff-skills}/skills/commit";
      recursive = true;
    };

    home.file.".claude/skills/github" = {
      source = "${agent-stuff-skills}/skills/github";
      recursive = true;
    };

    home.file.".claude/skills/summarize" = {
      source = "${agent-stuff-skills}/skills/summarize";
      recursive = true;
    };

    home.file.".claude/skills/native-web-search" = {
      source = "${agent-stuff-skills}/skills/native-web-search";
      recursive = true;
    };

    # Merge two JSON files (deep merge, second overrides first) into a target.
    # If the overlay is missing, fall back to the base unchanged.
    home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mergeJson() {
        local target="$1" base="$2" overlay="$3"
        local tmp
        tmp=$(mktemp)
        if [ -f "$base" ] && [ -f "$overlay" ]; then
          ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$base" "$overlay" > "$tmp"
        elif [ -f "$overlay" ]; then
          cp "$overlay" "$tmp"
        else
          cp "$base" "$tmp"
        fi
        run chmod u+w "$target" 2>/dev/null || true
        run mv "$tmp" "$target"
      }

      run mkdir -p "$HOME/.claude"
      run chmod u+w "$HOME/.claude" 2>/dev/null || true

      # ~/.claude/settings.json: nix-managed base + optional private overlay
      mergeJson "$HOME/.claude/settings.json" \
        "${./claude/settings.json}" \
        "$HOME/.claude/settings.private.json"

      # ~/.claude.json is owned by Claude Code; merge MCP servers into it
      mergeJson "$HOME/.claude.json" \
        "$HOME/.claude.json" \
        "${./claude/mcp-servers.json}"
    '';

  };
}
