{
  config,
  lib,
  pkgs,
  ...
}:
let
  claude-code = pkgs.callPackage ./claude/package.nix { };
  skills = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "skills";
    rev = "ab04fc11e0cc71fefce85f051d32c61f726e07ca";
    hash = "sha256-Qsc2nLoQdu7ac4phhxqmN6wN+lUFPhWFu2MSwSuBxr4=";
  };
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [
      claude-code
      pkgs.uv
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
      source = "${skills}/skills";
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

      # generate pagerduty-mcp entry with resolved uvx path
      pagerdutyMcp=$(${lib.getExe pkgs.jq} -n \
        --arg uvx "${lib.getBin pkgs.uv}/bin/uvx" \
        '{mcpServers: {"pagerduty-mcp": {type: "stdio", command: $uvx, args: ["pagerduty-mcp", "--enable-write-tools"]}}}')
      echo "$pagerdutyMcp" > /tmp/pagerduty-mcp.json

      # ~/.claude.json is owned by Claude Code; merge MCP servers into it
      mergeJson "$HOME/.claude.json" \
        "$HOME/.claude.json" \
        "${./claude/mcp-servers.json}"

      mergeJson "$HOME/.claude.json" \
        "$HOME/.claude.json" \
        "/tmp/pagerduty-mcp.json"

    '';

  };
}
