# The user-level skill set shared by Claude Code (claude.nix), Codex
# (codex.nix), and pi (which rides codex's copy): davegallant/skills plus a few
# skills cherry-picked from mattpocock/skills and flattened out of its category
# directories. Most of that repo overlaps skills we already have, so only the
# ones listed below are pulled in.
{
  pkgs,
  mattpocockSkills,
}:
let
  inherit (pkgs) lib;
  skillsPin = import ./skills.nix;
  own = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "skills";
    inherit (skillsPin) rev hash;
  };
  vendored = {
    handoff = "productivity/handoff";
    resolving-merge-conflicts = "engineering/resolving-merge-conflicts";
    wizard = "engineering/wizard";
  };
in
pkgs.runCommand "agent-skills" { } (
  ''
    mkdir -p "$out"
    cp -rL ${own}/skills/. "$out"
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
