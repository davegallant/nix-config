{
  lib,
  pkgs,
  ...
}:
let
  claude-code = pkgs.callPackage ./claude/package.nix { };
  skillsPin = import ./lib/skills.nix;
  skills = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "skills";
    inherit (skillsPin) rev hash;
  };
in
{
  home.packages = [
    claude-code
    pkgs.uv
  ];

  home.file.".claude/statusline-command.sh" = {
    source = ./claude/statusline-command.sh;
    executable = true;
  };

  home.file.".claude/claude-resume.sh" = {
    source = ./claude/claude-resume.sh;
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
  '';
}
