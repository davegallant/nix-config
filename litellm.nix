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
            geminiModel = name: {
              model_name = builtins.replaceStrings [ "." ] [ "-" ] name;
              litellm_params = {
                model = "gemini/${name}";
                api_key = "os.environ/GEMINI_API_KEY";
              };
            };
          in
          map copilotModel (import ./copilot-models.nix) ++ map geminiModel (import ./gemini-models.nix);
        litellm_settings = {
          drop_params = true;
        };
      };
    };
  };
}
