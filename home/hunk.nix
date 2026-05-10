{
  config,
  lib,
  pkgs,
  ...
}:
let
  hunk = pkgs.callPackage ./hunk/package.nix { };
  hunk-review-skill = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/modem-dev/hunk/v${hunk.version}/skills/hunk-review/SKILL.md";
    hash = "sha256-ULIHQn0nTUv75ljagujK/eOF3mejKQZtn+2bsB67j/8=";
  };
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [ hunk ];

    # claude: ~/.claude/skills/hunk-review/SKILL.md
    home.file.".claude/skills/hunk-review/SKILL.md".source = hunk-review-skill;

    # pi: ~/.pi/agent/skills/hunk-review/SKILL.md
    home.file.".pi/agent/skills/hunk-review/SKILL.md".source = hunk-review-skill;
  };
}
