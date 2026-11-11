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
  # Only kratos routes through litellm, keeping the internal URL and secret
  # out of this public repo: base_url is copied from $LITELLM_BASE_URL when
  # config.toml is first created (delete the file to pick up a new URL), and
  # the key is read from env_key at runtime. Other hosts fall back to codex's default ChatGPT-login auth
  # (`codex login`), riding whatever ChatGPT plan is signed in there.
  litellmProvider = ''
    model_provider = "litellm"

    [model_providers.litellm]
    name = "LiteLLM"
    base_url = "''${LITELLM_BASE_URL:-}/v1"
    env_key = "LITELLM_API_KEY"
    wire_api = "responses"

  '';

  ollamaModel = import ./lib/ollama.nix;
  ollamaBaseUrl = (import ./lib/ollama-endpoint.nix hostname).baseUrl;

  # Defaults written to the seed config and forced on every launch, so
  # wrapper launches always use them even if config.toml has gone stale.
  defaults = {
    model = "gpt-6-luna";
    model_reasoning_effort = "medium";
    sandbox_mode = "danger-full-access";
    approval_policy = "on-request";
  };
  statusLine = [
    "context-remaining"
    "five-hour-limit"
    "weekly-limit"
    "model-with-reasoning"
    "thread-title"
  ];
  # JSON strings and arrays are valid TOML values.
  toToml = builtins.toJSON;
  seedDefaults = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k} = ${toToml v}") defaults);
  defaultFlags = lib.escapeShellArgs (
    lib.concatMap
      (setting: [
        "--config"
        setting
      ])
      (
        lib.mapAttrsToList (k: v: "${k}=${toToml v}") defaults
        ++ [
          "tui.status_line=${toToml statusLine}"
          "tui.status_line_use_colors=true"
        ]
      )
  );

  # Create defaults once, then let Codex retain mutable state such as trusted
  # project decisions in ~/.codex/config.toml.
  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    mkdir -p "$HOME/.codex"

    if [ ! -f "$HOME/.codex/config.toml" ]; then
      cat > "$HOME/.codex/config.toml" <<EOF
      ${seedDefaults}

      ${lib.optionalString (hostname == "kratos") litellmProvider}[features]
      code_mode_host = true

      [tui]
      status_line = ${toToml statusLine}
      status_line_use_colors = true
      vim_mode_default = true
    EOF
    fi

    exec ${codex-pkg}/bin/codex ${defaultFlags} \
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
    home.file.".codex/AGENTS.md".source = pkgs.concatText "AGENTS.md" [
      ./instructions/links.md
      ./instructions/commits.md
    ];

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
