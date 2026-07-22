{
  lib,
  pkgs,
  hostname ? "",
  ...
}:
let
  codex-pkg = pkgs.callPackage ./codex/package.nix { };
  skillsPin = import ./lib/skills.nix;
  skills = pkgs.fetchFromGitHub {
    owner = "davegallant";
    repo = "skills";
    inherit (skillsPin) rev hash;
  };
  # Wrapper regenerates ~/.codex/config.toml on each run (like the pi wrapper's
  # models.json), so model/provider stay nix-managed. base_url is read from
  # $LITELLM_BASE_URL and the key via env_key at runtime, keeping the internal
  # URL and secret out of this public repo.
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    mkdir -p "$HOME/.codex"

    cat > "$HOME/.codex/config.toml" <<EOF
    model = "gpt-5.6-sol"
    model_provider = "litellm"

    [model_providers.litellm]
    name = "LiteLLM"
    base_url = "''${LITELLM_BASE_URL:-}/v1"
    env_key = "LITELLM_API_KEY"
    wire_api = "responses"
    EOF

    exec ${codex-pkg}/bin/codex "$@"
  '';
in
{
  config = lib.mkIf (hostname == "kratos") {
    home.packages = [ codex-wrapper ];

    # Shared skills: same davegallant/skills pin as claude (~/.claude/skills)
    # and pi. codex scans ~/.agents/skills for user-level skills.
    home.file.".agents/skills" = {
      source = "${skills}/skills";
      recursive = true;
    };
  };
}
