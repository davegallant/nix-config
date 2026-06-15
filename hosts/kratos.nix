{
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

  environment.systemPackages = [
    unstable.ollama
    unstable.terraform
  ];

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
    "zulu@8" # Java 8 runtime required by Cisco ASDM-IDM Launcher
  ];
}
