# The user-level skill set shared by Claude Code (claude.nix), Codex
# (codex.nix), and pi (which rides codex's copy): the skills in home/skills plus
# a few cherry-picked from mattpocock/skills and flattened out of its category
# directories. Most of that repo overlaps skills we already have, so only the
# ones listed below are pulled in. It is a flake input, so the weekly
# flake-update workflow bumps it.
{
  pkgs,
  mattpocockSkills,
}:
let
  inherit (pkgs) lib;
  vendored = {
    grilling = "productivity/grilling";
    handoff = "productivity/handoff";
    wizard = "engineering/wizard";
    writing-for-agents = "productivity/writing-for-agents";
  };
in
pkgs.runCommand "agent-skills" { } (
  ''
    mkdir -p "$out"
    cp -rL ${../skills}/. "$out"
  ''
  + lib.concatStrings (
    lib.mapAttrsToList (name: path: ''
      cp -rL ${mattpocockSkills}/skills/${path} "$out/${name}"
    '') vendored
  )
  + ''
    chmod -R u+w "$out"
  ''
)
