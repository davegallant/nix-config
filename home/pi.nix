{
  lib,
  pkgs,
  hostname ? "",
  ...
}:
let
  pi-pkg = pkgs.callPackage ./pi/package.nix {
    inherit (pkgs) python3;
  };

  onKratos = hostname == "kratos";
  modelProvider = if onKratos then "litellm" else "openai-codex";

  litellmProvider = ''
    "litellm": {
      baseUrl: $litellmBaseUrl,
      api: "openai-responses",
      apiKey: "$LITELLM_API_KEY",
      models: [
        { id: "gpt-5.6-luna", name: "GPT-5.6 Luna (litellm)", reasoning: true, input: ["text", "image"], contextWindow: 1050000, maxTokens: 128000 },
        { id: "gpt-5.6-terra", name: "GPT-5.6 Terra (litellm)", reasoning: true, input: ["text", "image"], contextWindow: 1050000, maxTokens: 128000 },
        { id: "gpt-5.6-sol", name: "GPT-5.6 Sol (litellm)", reasoning: true, input: ["text", "image"], contextWindow: 1050000, maxTokens: 128000 }
      ],
    },
  '';

  pi-wrapper = pkgs.writeShellScriptBin "pi" ''
    set -euo pipefail

    litellm_base_url=""
    ${lib.optionalString onKratos ''
      : "''${LITELLM_BASE_URL:?LITELLM_BASE_URL must be set}"
      : "''${LITELLM_API_KEY:?LITELLM_API_KEY must be set}"
      litellm_base_url="''${LITELLM_BASE_URL%/}/v1"
    ''}

    mkdir -p "$HOME/.pi/agent"

    ${pkgs.jq}/bin/jq -n --arg litellmBaseUrl "$litellm_base_url" '
      {
        providers: {
          "openai-codex": {
            modelOverrides: {
              "gpt-5.6-luna": { contextWindow: 1050000 },
              "gpt-5.6-terra": { contextWindow: 1050000 },
              "gpt-5.6-sol": { contextWindow: 1050000 },
            },
          },
    ${lib.optionalString onKratos litellmProvider}        },
      }
    ' > "$HOME/.pi/agent/models.json"

    export PI_ADVISOR_PROVIDER=${modelProvider}
    export PI_ADVISOR_MODEL=gpt-5.6-sol

    PI_SKIP_VERSION_CHECK=1 exec ${pi-pkg}/bin/pi "$@"
  '';
in
{
  config = {
    home.packages = [
      pi-wrapper
      pkgs.nodejs # required for pi to install git packages (npm install)
    ];

    home.file.".pi/agent/extensions/statusline.ts".source = ./pi/statusline.ts;

    # Attaches image paths in the prompt as real image content on submit, so
    # Ctrl+V pastes reach the model directly instead of costing a `read` call.
    home.file.".pi/agent/extensions/image-paste.ts".source = ./pi/image-paste.ts;

    # Advisor tool: consults a stronger model with the full session transcript.
    # The model is runtime-switchable via /advisor-model (persisted to
    # ~/.pi/agent/advisor.json, deliberately not nix-managed so it stays
    # writable). To pin it declaratively instead, set PI_ADVISOR_PROVIDER /
    # PI_ADVISOR_MODEL in the wrapper above.
    home.file.".pi/agent/extensions/advisor.ts".source = ./pi/advisor.ts;

    # AskUserQuestion equivalent: lets the model stop and offer choices mid-task.
    # Vendored from pi's bundled examples, plus promptGuidelines and a
    # sequential execution mode. Distinct from /answer (agent-stuff), which
    # extracts questions after the fact.
    home.file.".pi/agent/extensions/questionnaire.ts".source = ./pi/questionnaire.ts;

    # Claude-Code-parity prompt templates (/plan, /recap, /security-review,
    # /simplify, /verify). Pi auto-discovers templates in ~/.pi/agent/prompts/*.md.
    home.file.".pi/agent/prompts/plan.md".source = ./pi/prompts/plan.md;
    home.file.".pi/agent/prompts/recap.md".source = ./pi/prompts/recap.md;
    home.file.".pi/agent/prompts/security-review.md".source = ./pi/prompts/security-review.md;
    home.file.".pi/agent/prompts/simplify.md".source = ./pi/prompts/simplify.md;
    home.file.".pi/agent/prompts/verify.md".source = ./pi/prompts/verify.md;

    home.file.".pi/agent/settings.json".text = builtins.toJSON {
      defaultProvider = modelProvider;
      defaultModel = "gpt-5.6-terra";
      defaultThinkingLevel = "high";
      collapseChangelog = true;
      enabledModels = map (model: "${modelProvider}/${model}") [
        "gpt-5.6-luna"
        "gpt-5.6-terra"
        "gpt-5.6-sol"
      ];
      # davegallant/skills isn't declared here: pi auto-discovers skills from
      # ~/.agents/skills, which codex.nix already materializes from the same
      # pin (see home/lib/skills.nix). Declaring it again as a package source
      # just clones a second, independently-drifting copy and produces
      # startup "skill conflict" collision warnings.
      packages = [
        {
          source = "git:github.com/mitsuhiko/agent-stuff@13bc8f87970bec8830aab0f1c0487d35aa7c0917";
          skills = [ ];
          extensions = [
            "extensions/btw.ts"
            "extensions/continue.ts"
            "extensions/control.ts"
            "extensions/files.ts"
            "extensions/notify.ts"
            "extensions/review.ts"
            "extensions/subagent.ts"
            "extensions/whimsical.ts"
          ];
        }
        { source = "npm:pi-vimmode@0.9.0"; }
        { source = "git:github.com/obra/superpowers@v6.3.0"; }
      ];
    };
  };
}
