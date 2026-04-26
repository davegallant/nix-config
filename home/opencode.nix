{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  opencode-sandbox = pkgs.writeShellScriptBin "opencode" ''
    set -euo pipefail

    project="$(pwd)"
    uid="$(id -u)"
    xdg_runtime="''${XDG_RUNTIME_DIR:-/run/user/$uid}"

    mkdir -p \
      "$HOME/.config/opencode" \
      "$HOME/.local/share/opencode" \
      "$HOME/.cache/opencode"

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
      ${unstable.opencode}/bin/opencode "$@"
  '';
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [ opencode-sandbox ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      autoupdate = false;
      theme = "system";
      model = "litellm/gpt-4-1";
      permission = {
        bash = {
          "*" = "ask";
          "git *" = "allow";
          "git commit *" = "ask";
          "git push *" = "deny";
          "grep *" = "allow";
          "cat *" = "allow";
          "ls *" = "allow";
          "rm *" = "deny";
          "sudo *" = "deny";
          "chmod 777 *" = "deny";
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
        "github-copilot"
        "google"
      ];
      provider.litellm = {
        npm = "@ai-sdk/openai-compatible";
        name = "LiteLLM";
        options = {
          baseURL = "http://127.0.0.1:4000/v1";
          apiKey = "sk-noauth";
        };
        models =
          let
            mkModel = id: {
              name = id;
              tool_call = true;
              reasoning = false;
              attachment = true;
              limit = {
                context = 200000;
                output = 8192;
              };
              cost = {
                input = 0;
                output = 0;
              };
            };
          in
          builtins.listToAttrs (
            map (id: {
              name = builtins.replaceStrings [ "." ] [ "-" ] id;
              value = mkModel id;
            }) (import ../copilot-models.nix ++ import ../gemini-models.nix)
          );
      };
    };
  };
}
