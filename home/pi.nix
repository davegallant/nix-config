{
  pkgs,
  ...
}:
let
  skillsPin = import ./lib/skills.nix;
  pi-pkg = pkgs.callPackage ./pi/package.nix {
    inherit (pkgs) python3;
  };
  # Deliberately unsandboxed, and identical on Linux and macOS. Linux used to
  # run pi under bubblewrap, but macOS had no equivalent, so behaviour diverged
  # per platform. pi now runs with the same access the shell that launched it
  # has, everywhere.
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
    home.file.".pi/agent/extensions/auto-recap.ts".source = ./pi/auto-recap.ts;

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
      defaultModel = "glm-5.2";
      defaultThinkingLevel = "low";
      collapseChangelog = true;
      packages = [
        {
          source = "git:github.com/mitsuhiko/agent-stuff@d265b8ef32f896d3ef3bc6a45bd7b8e0d02150e0";
          skills = [ ]; # skip loading skills
          extensions = [
            "extensions/answer.ts"
            "extensions/btw.ts"
            "extensions/control.ts"
            "extensions/files.ts"
            "extensions/loop.ts"
            "extensions/notify.ts"
            "extensions/review.ts"
            "extensions/whimsical.ts"
          ];
        }
        {
          source = "git:github.com/davegallant/skills@${skillsPin.rev}";
        }
      ];
    };
  };
}
