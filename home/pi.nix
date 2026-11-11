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
  modelProvider = if onKratos then "litellm" else "openrouter";
  defaultModel = if onKratos then "gpt-6-luna" else "openai/gpt-6-luna";
  solModel = if onKratos then "gpt-6-sol" else "openai/gpt-6-sol";
  ollamaModel = import ./lib/ollama.nix;
  ollamaBaseUrl = (import ./lib/ollama-endpoint.nix hostname).baseUrl;

  mkModel =
    id: name: limits:
    {
      inherit id name;
      reasoning = true;
      input = [
        "text"
        "image"
      ];
    }
    // limits;
  gpt6Limits = {
    contextWindow = 1050000;
    maxTokens = 128000;
  };

  modelsTemplate = pkgs.writeText "pi-models.json" (
    builtins.toJSON {
      providers = {
        ollama = {
          baseUrl = ollamaBaseUrl;
          api = "openai-completions";
          apiKey = "ollama";
          compat = {
            supportsDeveloperRole = false;
            supportsReasoningEffort = false;
          };
          models = [ ollamaModel ];
        };
        openrouter.models = [
          (mkModel "openai/gpt-6-luna" "GPT-6 Luna (OpenRouter)" gpt6Limits)
          (mkModel "openai/gpt-6-sol" "GPT-6 Sol (OpenRouter)" gpt6Limits)
          (mkModel "deepseek/deepseek-v4.1-flash" "DeepSeek V4.1 Flash (OpenRouter)" {
            contextWindow = 1048576;
            maxTokens = 1048576;
          })
        ];
      }
      // lib.optionalAttrs onKratos {
        litellm = {
          # Resolve the private gateway URL at launch, outside the Nix store.
          baseUrl = "";
          api = "openai-responses";
          apiKey = "$LITELLM_API_KEY";
          # Cost is left unset until authoritative gateway pricing is available.
          models = [
            (mkModel defaultModel "GPT-6 Luna (litellm)" gpt6Limits)
            (mkModel solModel "GPT-6 Sol (litellm)" gpt6Limits)
            (mkModel "gpt-6.1-sol" "GPT-6.1 Sol (litellm)" {
              contextWindow = 1000000;
              maxTokens = 131072;
            })
            (mkModel "gemini-4-argon" "Gemini 4 Argon (litellm)" {
              contextWindow = 1048576;
              maxTokens = 65536;
            })
          ];
        };
      };
    }
  );

  pi-wrapper = pkgs.writeShellScriptBin "pi" ''
    set -euo pipefail
    export PI_SKIP_VERSION_CHECK=1

    case "''${1:-}" in
      -h|--help|-v|--version)
        exec ${pi-pkg}/bin/pi "$@"
        ;;
    esac

    agent_dir="''${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
    models_file="$agent_dir/models.json"
    models_source=${modelsTemplate}
    temporary_models=""

    cleanup() {
      if [[ -n "$temporary_models" && -e "$temporary_models" ]]; then
        ${pkgs.coreutils}/bin/rm -- "$temporary_models"
      fi
    }
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM

    ${lib.optionalString onKratos ''
      : "''${LITELLM_BASE_URL:?LITELLM_BASE_URL must be set}"
      : "''${LITELLM_API_KEY:?LITELLM_API_KEY must be set}"
      litellm_base_url="''${LITELLM_BASE_URL%/}"
      if [[ "$litellm_base_url" != */v1 ]]; then
        litellm_base_url="$litellm_base_url/v1"
      fi

      gateway_hash="$(printf '%s' "$litellm_base_url" | ${pkgs.coreutils}/bin/sha256sum)"
      gateway_hash="''${gateway_hash%% *}"
      models_cache="$agent_dir/cache/models/${builtins.baseNameOf (toString modelsTemplate)}"
      models_source="$models_cache/$gateway_hash.json"

      if [[ ! -s "$models_source" ]]; then
        ${pkgs.coreutils}/bin/mkdir -p -m 700 "$models_cache"
        temporary_models="$(${pkgs.coreutils}/bin/mktemp "$models_cache/.models.XXXXXXXX")"
        ${pkgs.jq}/bin/jq --arg baseUrl "$litellm_base_url" \
          '.providers.litellm.baseUrl = $baseUrl' ${modelsTemplate} > "$temporary_models"
        ${pkgs.coreutils}/bin/mv -- "$temporary_models" "$models_source"
        temporary_models=""
      fi
    ''}

    if ! ${pkgs.diffutils}/bin/cmp -s "$models_source" "$models_file"; then
      ${pkgs.coreutils}/bin/mkdir -p -m 700 "$agent_dir"
      temporary_models="$(${pkgs.coreutils}/bin/mktemp "$agent_dir/.models.XXXXXXXX")"
      ${pkgs.coreutils}/bin/cp -- "$models_source" "$temporary_models"
      ${pkgs.coreutils}/bin/mv -- "$temporary_models" "$models_file"
      temporary_models=""
    fi

    exec ${pi-pkg}/bin/pi "$@"
  '';
in
{
  config = {
    home.packages = [
      pi-wrapper
      pkgs.nodejs # required for pi to install git packages (npm install)
    ];

    home.file.".pi/agent/extensions/statusline.ts".source = ./pi/statusline.ts;

    # Prevent rare, oversized read/bash results from inflating every later turn.
    home.file.".pi/agent/extensions/token-budget.ts".source = ./pi/token-budget.ts;

    home.file.".pi/agent/extensions/litellm-compat.ts".source = ./pi/litellm-compat.ts;

    # Attaches image paths in the prompt as real image content on submit, so
    # Ctrl+V pastes reach the model directly instead of costing a `read` call.
    home.file.".pi/agent/extensions/image-paste.ts".source = ./pi/image-paste.ts;

    # AskUserQuestion equivalent: lets the model stop and offer choices mid-task.
    # Vendored from pi's bundled examples, plus promptGuidelines and a
    # sequential execution mode. Distinct from /answer (agent-stuff), which
    # extracts questions after the fact.
    home.file.".pi/agent/extensions/questionnaire.ts".source = ./pi/questionnaire.ts;

    # Global instructions, shared with Claude and Codex (voice.md is Claude-only).
    home.file.".pi/agent/AGENTS.md".source = pkgs.concatText "AGENTS.md" [
      ./instructions/links.md
      ./instructions/commits.md
      ./instructions/reviews.md
    ];

    # Claude-Code-parity prompt templates (/plan, /recap, /security-review,
    # /simplify, /verify). Pi auto-discovers templates in ~/.pi/agent/prompts/*.md.
    home.file.".pi/agent/prompts" = {
      source = ./pi/prompts;
      recursive = true;
    };

    home.file.".pi/agent/settings.json".text = builtins.toJSON {
      defaultProvider = modelProvider;
      inherit defaultModel;
      defaultThinkingLevel = "medium";
      modelThinkingLevels."${modelProvider}/${defaultModel}" = "medium";
      thinkingBudgets = {
        low = 1024;
        medium = 4096;
        high = 8192;
      };
      # Compact before long tool-heavy sessions repeatedly replay their history.
      compaction = {
        reserveTokens = 13600;
        keepRecentTokens = 20000;
      };
      collapseChangelog = true;
      enabledModels = [
        "ollama/${ollamaModel.id}"
        "${modelProvider}/${defaultModel}"
        "${modelProvider}/${solModel}"
        "openrouter/deepseek/deepseek-v4.1-flash"
      ]
      ++ lib.optionals onKratos [
        "litellm/gpt-6.1-sol"
        "litellm/gemini-4-argon"
      ];
      # Skills (home/skills + obra/superpowers + a few from
      # mattpocock/skills) aren't declared here: pi auto-discovers
      # ~/.agents/skills, which codex.nix materializes from the same pins (see
      # home/lib/skillset.nix). Declaring any of them
      # again as a package source clones a second, independently-drifting
      # copy and produces startup "skill conflict" collision warnings.
      packages = [
        {
          source = "git:github.com/mitsuhiko/agent-stuff@0865c849befd2021490679f96a8dee58c84ac857";
          skills = [ ];
          extensions = [
            "extensions/btw.ts"
            "extensions/continue.ts"
            "extensions/files.ts"
            "extensions/notify.ts"
            "extensions/review.ts"
            "extensions/subagent.ts"
            "extensions/whimsical.ts"
          ];
        }
        { source = "npm:pi-vimmode@0.9.0"; }
      ];
    };
  };
}
