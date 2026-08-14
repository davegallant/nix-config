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
  # Only kratos routes through litellm (base_url from $LITELLM_BASE_URL, key
  # via env_key at runtime, keeping the internal URL and secret out of this
  # public repo). Other hosts fall back to codex's default ChatGPT-login auth
  # (`codex login`), riding whatever ChatGPT plan is signed in there.
  litellmProvider = ''
    model = "gpt-5.6-luna"
    model_provider = "litellm"

    [model_providers.litellm]
    name = "LiteLLM"
    base_url = "''${LITELLM_BASE_URL:-}/v1"
    env_key = "LITELLM_API_KEY"
    wire_api = "responses"

  '';

  # Wrapper regenerates ~/.codex/config.toml on each run (like the pi wrapper's
  # models.json), so config stays nix-managed.
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    mkdir -p "$HOME/.codex"

    cat > "$HOME/.codex/config.toml" <<EOF
    ${lib.optionalString (hostname == "kratos") litellmProvider}[tui]
    status_line = [ "current-dir", "git-branch", "model", "context-remaining" ]
    vim_mode_default = true
    EOF

    exec ${codex-pkg}/bin/codex "$@"
  '';
in
{
  config = {
    home.packages = [ codex-wrapper ];

    # Shared skills: same davegallant/skills pin as claude (~/.claude/skills)
    # and pi. codex scans ~/.agents/skills for user-level skills, but its
    # walker ignores symlinked SKILL.md files, so home.file symlinks are
    # invisible to it. Materialize real files by copying (deref) from the
    # store instead.
    home.activation.codexSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run rm -rf "$HOME/.agents/skills"
      run mkdir -p "$HOME/.agents"
      run cp -rL "${skills}/skills" "$HOME/.agents/skills"
      run chmod -R u+w "$HOME/.agents/skills"
    '';
  };
}
