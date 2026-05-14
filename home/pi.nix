{
  config,
  lib,
  pkgs,
  ...
}:
let
  pi-pkg = pkgs.callPackage ./pi/package.nix {
    python3 = pkgs.python3;
  };
  pi-wrapper = pkgs.writeShellScriptBin "pi" (
    ''
      set -euo pipefail

      mkdir -p "$HOME/.pi/agent"

      litellm_base_url="''${LITELLM_BASE_URL:-''${ANTHROPIC_BASE_URL:-http://127.0.0.1:4000/v1}}"
      litellm_api_key="''${LITELLM_API_KEY:-''${ANTHROPIC_AUTH_TOKEN:-sk-noauth}}"
      models_json="$HOME/.config/nix-config/litellm-models.json"

      if [ -f "$models_json" ]; then
        ${pkgs.jq}/bin/jq -n \
          --arg base_url "$litellm_base_url" \
          --arg api_key "$litellm_api_key" \
          --slurpfile m "$models_json" '
          {
            providers: {
              litellm: {
                baseUrl: $base_url,
                api: "openai-completions",
                apiKey: $api_key,
                compat: {
                  cacheControlFormat: "anthropic",
                },
                models: (
                  $m[0] | to_entries
                  | map({
                    id: .key,
                    name: .value.name,
                    reasoning: .value.reasoning,
                    input: (if .value.attachment then ["text", "image"] else ["text"] end),
                    contextWindow: (if .value.limit.context > 0 then .value.limit.context else 128000 end),
                    maxTokens: (if .value.limit.output > 0 then .value.limit.output else 16384 end),
                    cost: {
                      input: .value.cost.input,
                      output: .value.cost.output,
                      cacheRead: (.value.cost.input / 10),
                      cacheWrite: (.value.cost.input * 1.25),
                    },
                  })
                ),
              },
            },
          }
        ' > "$HOME/.pi/agent/models.json"
      else
        ${pkgs.jq}/bin/jq -n \
          --arg base_url "$litellm_base_url" \
          --arg api_key "$litellm_api_key" '
          {
            providers: {
              litellm: {
                baseUrl: $base_url,
                api: "openai-completions",
                apiKey: $api_key,
                compat: {
                  cacheControlFormat: "anthropic",
                },
                models: [],
              },
            },
          }
        ' > "$HOME/.pi/agent/models.json"
      fi
    ''
    + lib.optionalString pkgs.stdenv.isLinux ''

      project="$(pwd)"
      uid="$(id -u)"
      xdg_runtime="''${XDG_RUNTIME_DIR:-/run/user/$uid}"

      ssh_auth_bind=()
      if [ -n "''${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
        ssh_auth_bind=(--bind "$SSH_AUTH_SOCK" "$SSH_AUTH_SOCK" --setenv SSH_AUTH_SOCK "$SSH_AUTH_SOCK")
      fi

      exec ${pkgs.bubblewrap}/bin/bwrap \
        --unshare-all \
        --share-net \
        --die-with-parent \
        --ro-bind /nix/store /nix/store \
        --ro-bind /run/current-system /run/current-system \
        --ro-bind /run/wrappers /run/wrappers \
        --ro-bind /etc/profiles/per-user/"$USER" /etc/profiles/per-user/"$USER" \
        --ro-bind /etc/resolv.conf /etc/resolv.conf \
        --ro-bind /etc/hosts /etc/hosts \
        --ro-bind /etc/nsswitch.conf /etc/nsswitch.conf \
        --ro-bind /etc/passwd /etc/passwd \
        --ro-bind /etc/group /etc/group \
        --ro-bind /etc/ssl /etc/ssl \
        --ro-bind /etc/static /etc/static \
        --ro-bind-try /etc/localtime /etc/localtime \
        --ro-bind-try /etc/zoneinfo /etc/zoneinfo \
        --ro-bind-try /etc/timezone /etc/timezone \
        --ro-bind-try /etc/terminfo /etc/terminfo \
        --ro-bind-try "$HOME/.gitconfig" "$HOME/.gitconfig" \
        --ro-bind-try "$HOME/.config/git" "$HOME/.config/git" \
        --ro-bind-try "$HOME/.config/gh" "$HOME/.config/gh" \
        --ro-bind-try "$HOME/.ssh" "$HOME/.ssh" \
        --ro-bind-try "$HOME/.gnupg" "$HOME/.gnupg" \
        --bind "$HOME/.pi" "$HOME/.pi" \
        --bind "$project" "$project" \
        --chdir "$project" \
        --dev /dev \
        --proc /proc \
        --tmpfs /tmp \
        --tmpfs /run/user \
        --dir "$xdg_runtime" \
        --bind-try "$xdg_runtime/gnupg" "$xdg_runtime/gnupg" \
        "''${ssh_auth_bind[@]}" \
        --setenv HOME "$HOME" \
        --setenv XDG_RUNTIME_DIR "$xdg_runtime" \
        --setenv LANG "''${LANG:-en_US.UTF-8}" \
        --setenv TZ "''${TZ:-}" \
        --setenv PATH "/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/run/wrappers/bin" \
        ${pi-pkg}/bin/pi "$@"
    ''
    + lib.optionalString pkgs.stdenv.isDarwin ''

      exec ${pi-pkg}/bin/pi "$@"
    ''
  );
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [
      pi-wrapper
    ];

    home.file.".pi/agent/extensions/statusline.ts".source = ./pi/statusline.ts;

    home.file.".pi/agent/settings.json".text = builtins.toJSON {
      defaultProvider = "litellm";
      defaultModel = "claude-sonnet-4-6";
      autoCompact = false;
      thinking = "low";
      packages = [
        {
          source = "git:github.com/mitsuhiko/agent-stuff@ab79f98104bcd3c6a7c5491e609f6d6700a7414d";
          extensions = [
            "extensions/answer.ts"
            "extensions/btw.ts"
            "extensions/control.ts"
            "extensions/files.ts"
            "extensions/go-to-bed.ts"
            "extensions/loop.ts"
            "extensions/notify.ts"
            "extensions/prompt-editor.ts"
            "extensions/review.ts"
            "extensions/whimsical.ts"
          ];
        }
        {
          source = "git:github.com/davegallant/skills@8988cb86445a6989d9764011e03eac4edb70259c";
          skills = [
            "commit"
            "github"
            "grill-me"
            "hunk-review"
            "librarian"
            "native-web-search"
            "sentry"
            "summarize"
            "web-browser"
          ];
        }
      ];
    };
  };
}
