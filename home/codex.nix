{
  lib,
  pkgs,
  hostname ? "",
  mattpocockSkills,
  superpowers,
  ...
}:
let
  codex-pkg = pkgs.callPackage ./codex/package.nix { };
  skills = import ./lib/skillset.nix {
    inherit pkgs mattpocockSkills;
  };
  codexSkills = pkgs.runCommand "codex-skills" { } ''
    mkdir -p "$out/superpowers"
    cp -rL ${skills}/. "$out"
    cp -rL ${superpowers}/skills/. "$out/superpowers"
  '';
  # Only kratos routes through litellm (base_url from $LITELLM_BASE_URL, key
  # via env_key at runtime, keeping the internal URL and secret out of this
  # public repo). Other hosts fall back to codex's default ChatGPT-login auth
  # (`codex login`), riding whatever ChatGPT plan is signed in there.
  litellmProvider = ''
    model_provider = "litellm"

    [model_providers.litellm]
    name = "LiteLLM"
    base_url = "''${LITELLM_BASE_URL:-}/v1"
    env_key = "LITELLM_API_KEY"
    wire_api = "responses"

  '';

  # Local Ollama on kratos, reached over the tailnet from other hosts.
  ollamaModel = import ./lib/ollama.nix;
  ollamaBaseUrl =
    if hostname == "kratos" then "http://127.0.0.1:11434/v1" else "http://kratos:11434/v1";

  # Create defaults once, then let Codex retain mutable state such as trusted
  # project decisions in ~/.codex/config.toml.
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    mkdir -p "$HOME/.codex"

    if [ ! -f "$HOME/.codex/config.toml" ]; then
      cat > "$HOME/.codex/config.toml" <<EOF
      model = "gpt-6-luna"
      model_reasoning_effort = "medium"
      sandbox_mode = "danger-full-access"
      approval_policy = "on-request"

      ${lib.optionalString (hostname == "kratos") litellmProvider}[features]
      code_mode_host = true

      [tui]
      status_line = [ "context-remaining", "five-hour-limit", "weekly-limit", "model-with-reasoning", "thread-title" ]
      status_line_use_colors = true
      vim_mode_default = true
    EOF
    fi

    exec ${codex-pkg}/bin/codex \
      --config 'model="gpt-6-luna"' \
      --config 'model_reasoning_effort="medium"' \
      --config 'sandbox_mode="danger-full-access"' \
      --config 'approval_policy="on-request"' \
      --config 'tui.status_line=["context-remaining","five-hour-limit","weekly-limit","model-with-reasoning","thread-title"]' \
      --config 'tui.status_line_use_colors=true' \
      "$@"
  '';

  # Profiles can't override the wrapper's `--config model=...`, so switch the
  # provider at the top level and pass the model with `-m`, which wins.
  codex-qwen = pkgs.writeShellScriptBin "codex-qwen" ''
    exec ${codex-wrapper}/bin/codex \
      --config 'model_providers.kratos-ollama.name="Ollama (kratos)"' \
      --config 'model_providers.kratos-ollama.base_url="${ollamaBaseUrl}"' \
      --config 'model_providers.kratos-ollama.wire_api="responses"' \
      --config 'model_provider="kratos-ollama"' \
      --config 'model_context_window=${toString ollamaModel.contextWindow}' \
      -m '${ollamaModel.id}' \
      "$@"
  '';
in
{
  config = {
    home.packages = [
      codex-wrapper
      codex-qwen
    ];

    # Global instructions loaded into every Codex session.
    home.file.".codex/AGENTS.md".source = ./instructions/links.md;

    # Codex scans ~/.agents/skills for user-level skills but ignores symlinked
    # SKILL.md files. Materialize the shared and Superpowers skills as real
    # files instead.
    home.activation.codexSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run rm -rf "$HOME/.agents/skills"
      run mkdir -p "$HOME/.agents"
      run cp -rL "${codexSkills}" "$HOME/.agents/skills"
      run chmod -R u+w "$HOME/.agents/skills"
    '';
  };
}
