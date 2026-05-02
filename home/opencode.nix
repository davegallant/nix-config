{
  config,
  lib,
  pkgs,
  ...
}:
let
  opencode = pkgs.callPackage ./opencode/package.nix {
    python3 = pkgs.python3;
    just = pkgs.just;
  };
  opencode-wrapper = pkgs.writeShellScriptBin "opencode" (
    ''
      set -euo pipefail

      mkdir -p \
        "$HOME/.config/opencode" \
        "$HOME/.local/share/opencode/log" \
        "$HOME/.cache/opencode"

      litellm_base_url="''${LITELLM_BASE_URL:-''${ANTHROPIC_BASE_URL:-http://127.0.0.1:4000/v1}}"
      litellm_api_key="''${LITELLM_API_KEY:-''${ANTHROPIC_AUTH_TOKEN:-sk-noauth}}"
      models_json="$HOME/.config/nix-config/litellm-models.json"
      rendered="$HOME/.config/opencode/opencode.json"
      sed \
        -e "s|__LITELLM_BASE_URL__|$litellm_base_url|g" \
        -e "s|__LITELLM_API_KEY__|$litellm_api_key|g" \
        "$HOME/.config/opencode/opencode.json.template" \
        > "$rendered.tmp"
      if [ -f "$models_json" ]; then
        ${pkgs.jq}/bin/jq --slurpfile m "$models_json" \
          '.provider.litellm.models = $m[0]' \
          "$rendered.tmp" > "$rendered"
        rm -f "$rendered.tmp"
      else
        mv "$rendered.tmp" "$rendered"
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
        --bind "$HOME/.config/opencode" "$HOME/.config/opencode" \
        --bind "$HOME/.local/share/opencode" "$HOME/.local/share/opencode" \
        --bind "$HOME/.cache/opencode" "$HOME/.cache/opencode" \
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
        ${opencode}/bin/opencode "$@"
    ''
    + lib.optionalString pkgs.stdenv.isDarwin ''

      exec ${opencode}/bin/opencode "$@"
    ''
  );
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [ opencode-wrapper ];

    xdg.configFile."opencode/opencode.json.template".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      autoupdate = false;
      theme = "system";
      model = "litellm/claude-sonnet-4-6";
      permission = {
        bash = {
          "*" = "ask";
          "cat *" = "allow";
          "chmod 777 *" = "deny";
          "curl *" = "allow";
          "dd *" = "deny";
          "git add *" = "allow";
          "git commit *" = "allow";
          "git diff *" = "allow";
          "git log *" = "allow";
          "git pull *" = "allow";
          "git push *" = "ask";
          "git push --force*" = "deny";
          "git push -f*" = "deny";
          "git status *" = "allow";
          "grep *" = "allow";
          "just *" = "allow";
          "ls *" = "allow";
          "make *" = "allow";
          "nix build *" = "allow";
          "nix flake *" = "allow";
          "rm *" = "deny";
          "sudo *" = "deny";
        };
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
          "*.key" = "deny";
          "*.pem" = "deny";
        };
        edit = "ask";
      };
      plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];
      disabled_providers = [
        "opencode"
        "openrouter"
        "github-copilot"
        "google"
      ];
      provider.litellm = {
        npm = "@ai-sdk/openai-compatible";
        name = "LiteLLM";
        options = {
          baseURL = "__LITELLM_BASE_URL__";
          apiKey = "__LITELLM_API_KEY__";
        };
        # Models are merged in at runtime by the opencode wrapper from
        # ~/.config/nix-config/litellm-models.json (populated by `just refresh-models`).
        # Empty here so the template stays pure / hermetic.
        models = { };
      };
    };
  };
}
