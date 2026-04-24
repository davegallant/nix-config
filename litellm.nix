{ config, lib, ... }:
{
  config = lib.mkIf config.features.ai.enable {
    services.litellm = {
      enable = true;
      host = "0.0.0.0";
      port = 4000;
      environment = {
        HOME = "/var/lib/litellm";
      };
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
          in
          map copilotModel (import ./copilot-models.nix);
        litellm_settings = {
          drop_params = true;
        };
      };
    };
  };
}
