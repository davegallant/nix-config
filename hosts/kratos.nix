{
  lib,
  pkgs,
  unstable,
  username,
  ...
}:
{
  networking.hostName = "kratos";

  home-manager.users.${username}.imports = [ ../home/claude.nix ];

  services.openssh.enable = true;

  system.defaults.dock = {
    autohide = true;
    tilesize = 50;
    orientation = "bottom";
    persistent-apps = [
      "/Applications/ghostty.app"
      "/Applications/Google Chrome.app"
      "/Applications/Obsidian.app"
      "/Applications/Slack.app"
      "/Applications/zoom.us.app"
    ];
  };

  environment.systemPackages = [
    pkgs.terraform-mcp-server
    unstable.kubelogin
    unstable.terraform
  ];

  homebrew.brews = lib.mkAfter [
    "azure-cli"
    "ollama"
    "node"
  ];

  homebrew.casks = lib.mkAfter [
    "1password"
    "1password-cli"
    "gcloud-cli"
    "headlamp"
    "orka3"
    "slack"
    "unity-cli"
    "zulu@8" # Java 8 runtime required by Cisco ASDM-IDM Launcher
  ];
}
