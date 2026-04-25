{
  config,
  lib,
  pkgs,
  ...
}:
let
  opencode-sandbox = pkgs.writeShellScriptBin "opencode" ''
    exec ${pkgs.bubblewrap}/bin/bwrap \
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
      --bind "$HOME" "$HOME" \
      --bind "$(pwd)" "$(pwd)" \
      --dev /dev \
      --proc /proc \
      --tmpfs /tmp \
      --setenv PATH "/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/run/wrappers/bin" \
      --die-with-parent \
      ${pkgs.opencode}/bin/opencode "$@"
  '';
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [ opencode-sandbox ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      autoupdate = false;
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
            }) (import ../copilot-models.nix)
          );
      };
    };
  };
}
