{
  config,
  hostname ? "",
  lib,
  ...
}:
let
  ollamaModel = import ./lib/ollama.nix;
  ollamaEndpoint = import ./lib/ollama-endpoint.nix hostname;
in
{
  launchd.agents.ollama = lib.mkIf (hostname == "kratos") {
    enable = true;
    config = {
      Label = "com.ollama.ollama";
      ProgramArguments = [
        "/opt/homebrew/opt/ollama/bin/ollama"
        "serve"
      ];
      EnvironmentVariables = {
        HOME = config.home.homeDirectory;
        OLLAMA_CONTEXT_LENGTH = toString ollamaModel.contextWindow;
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_HOST = "0.0.0.0:${toString ollamaEndpoint.port}";
        OLLAMA_KEEP_ALIVE = "-1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
      };
      KeepAlive = true;
      ProcessType = "Background";
      RunAtLoad = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ollama.log";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ollama.log";
      WorkingDirectory = "/opt/homebrew/var";
    };
  };
}
