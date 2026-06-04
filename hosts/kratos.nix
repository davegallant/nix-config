{
  pkgs,
  lib,
  unstable,
  ...
}:
{
  networking.hostName = "kratos";

  system.defaults.dock = {
    autohide = true;
    tilesize = 50;
    orientation = "bottom";
    persistent-apps = [
      "/Applications/ghostty.app"
      "/Applications/Google Chrome.app"
      "/Applications/Brave Browser.app"
      "/Applications/Obsidian.app"
      "/Applications/Slack.app"
      "/Applications/zoom.us.app"
    ];
  };

  environment.systemPackages = [ unstable.ollama ];

  launchd.daemons.ollama = {
    serviceConfig = {
      ProgramArguments = [
        "${unstable.ollama}/bin/ollama"
        "serve"
      ];
      EnvironmentVariables = {
        OLLAMA_HOST = "0.0.0.0:11434";
        OLLAMA_KEEP_ALIVE = "-1";
        OLLAMA_FLASH_ATTENTION = "1";
        HOME = "/var/root";
      };
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/ollama.log";
      StandardErrorPath = "/var/log/ollama.log";
    };
  };

  launchd.daemons.ollama-load-models = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.writeShellScript "ollama-load-models" ''
          until ${pkgs.curl}/bin/curl -sf http://localhost:11434/api/version > /dev/null 2>&1; do
            sleep 2
          done
          exec ${pkgs.curl}/bin/curl -sf http://localhost:11434/api/generate \
            -d '{"model":"qwen3.6:35b","keep_alive":-1}' -o /dev/null
        ''}"
      ];
      EnvironmentVariables = {
        HOME = "/var/root";
      };
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 300;
      StandardOutPath = "/var/log/ollama-load.log";
      StandardErrorPath = "/var/log/ollama-load.log";
    };
  };

  homebrew.brews = lib.mkAfter [
    "awscli"
    "azure-cli"
    "node"
    "oras"
  ];

  homebrew.casks = lib.mkAfter [
    "1password"
    "1password-cli"
    "gcloud-cli"
    "headlamp"
    "orka3"
    "slack"
  ];
}
