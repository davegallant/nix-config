{
  config,
  lib,
  unstable,
  ...
}:
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
      package = unstable.litellm;
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
            # 32k context fits most local 20-30B models on 64GB without OOM.
            # Ollama's default of 4096 silently truncates pi's system prompt + tools,
            # which causes models to emit partial JSON and stop mid-response.
            ollamaOpts = {
              num_ctx = 32768;
            };
            ollamaModel = name: {
              model_name = builtins.replaceStrings [ "." ] [ "-" ] name;
              litellm_params = {
                model = "ollama_chat/${name}";
                api_base = "http://localhost:11434";
              }
              // ollamaOpts;
            };
            ollamaModelAres = name: {
              model_name = builtins.replaceStrings [ "." ] [ "-" ] name;
              litellm_params = {
                model = "ollama_chat/${name}";
                api_base = "http://ares:11434";
              }
              // ollamaOpts;
            };
          in
          map copilotModel (import ./models/copilot.nix)
          ++ map openrouterModel (import ./models/openrouter.nix)
          ++ map ollamaModel [ "qwen3.5:9b" ]
          ++ map ollamaModelAres [ "qwen3.6:35b" ];
        litellm_settings = {
          drop_params = true;
        };
      };
    };
  };
}
