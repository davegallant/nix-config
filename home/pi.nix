{
  pkgs,
  ...
}:
let
  pi-pkg = pkgs.callPackage ./pi/package.nix {
    inherit (pkgs) python3;
  };
  pi-wrapper = pkgs.writeShellScriptBin "pi" ''
    set -euo pipefail

    mkdir -p "$HOME/.pi/agent"

    ${pkgs.jq}/bin/jq -n '
      {
        providers: {
          "ollama": {
            baseUrl: "http://kratos:11434/v1",
            api: "openai-completions",
            apiKey: "ollama",
            compat: {
              supportsDeveloperRole: false,
              supportsReasoningEffort: false,
              thinkingFormat: "qwen"
            },
            models: [
              { id: "qwen3.6:35b", name: "Qwen 3.6 35B (kratos)", reasoning: true, contextWindow: 262144 }
            ],
          },
        },
      }
    ' > "$HOME/.pi/agent/models.json"

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
      defaultProvider = "opencode-go";
      defaultModel = "deepseek-v4-pro";
      defaultThinkingLevel = "high";
      collapseChangelog = true;
      # Ctrl+P cycling, for A/B-ing the candidates on real work. kimi-k3 is
      # listed so the advisor's model stays inside the session scope that
      # enabledModels establishes.
      enabledModels = [
        "opencode-go/deepseek-v4-pro"
        "opencode-go/minimax-m3"
        "opencode-go/glm-5.2"
        "opencode-go/kimi-k3"
      ];
      # davegallant/skills isn't declared here: pi auto-discovers skills from
      # ~/.agents/skills, which codex.nix already materializes from the same
      # pin (see home/lib/skills.nix). Declaring it again as a package source
      # just clones a second, independently-drifting copy and produces
      # startup "skill conflict" collision warnings.
      packages = [
        {
          source = "git:github.com/mitsuhiko/agent-stuff@d265b8ef32f896d3ef3bc6a45bd7b8e0d02150e0";
          skills = [ ]; # skip loading skills
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
      ];
    };
  };
}
