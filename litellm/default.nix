{ config, lib, ... }:
{
  config = lib.mkIf config.features.ai.enable {
    system.activationScripts.litellm-secrets.text = ''
      if [ ! -f /var/lib/litellm/secrets.env ]; then
        mkdir -p /var/lib/litellm
        touch /var/lib/litellm/secrets.env
        chmod 600 /var/lib/litellm/secrets.env
      fi
    '';

    services.litellm = {
      enable = true;
      host = "127.0.0.1";
      port = 4000;
      environment = {
        HOME = "/var/lib/litellm";
        XDG_CONFIG_HOME = "/var/lib/litellm/.config";
      };
      environmentFile = "/var/lib/litellm/secrets.env";
      settings = {
        model_list =
          let
            copilotHeaders = {
              "editor-version" = "vscode/1.95.0";
              "Copilot-Integration-Id" = "vscode-chat";
            };
            copilotModel = name: {
              model_name = builtins.replaceStrings [ "." ] [ "-" ] name;
              litellm_params = {
                model = "github_copilot/${name}";
                extra_headers = copilotHeaders;
              };
            };
            openrouterModel = name: {
              model_name = builtins.replaceStrings [ "." ] [ "-" ] name;
              litellm_params = {
                model = "openrouter/${name}";
                api_key = "os.environ/OPENROUTER_API_KEY";
              };
            };
            ollamaModel = name: {
              model_name = builtins.replaceStrings [ "." ] [ "-" ] name;
              litellm_params = {
                model = "ollama/${name}";
                api_base = "http://localhost:11434";
              };
            };
          in
          map copilotModel (import ./models/copilot.nix)
          ++ map openrouterModel (import ./models/openrouter.nix)
          ++ map ollamaModel [ "qwen3.5:9b" ];
        litellm_settings = {
          drop_params = true;
        };
      };
    };
  };
}
