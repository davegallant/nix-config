{ pkgs, unstable, ... }:
{
  networking = {
    hostName = "kratos";
  };

  nix.enable = false;

  system.stateVersion = 4;

  users.users."dave.gallant".home = "/Users/dave.gallant";
  users.users."dave.gallant".shell = pkgs.fish;

  programs.fish.enable = true;

  system.primaryUser = "dave.gallant";

  system.defaults = {

    trackpad = {
      ActuationStrength = 0;
      Clicking = true;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      TrackpadRightClick = true;
    };

    dock = {
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

    WindowManager = {
      GloballyEnabled = false;
      EnableTilingByEdgeDrag = true;
      EnableTopTilingByEdgeDrag = true;
      EnableTilingOptionAccelerator = true;
      EnableTiledWindowMargins = false;
    };

    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowScrollBars = "Always";
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;
    finder.FXPreferredViewStyle = "Nlsv";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

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

  home-manager.users."dave.gallant".features.ai.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
      # Homebrew 4.x requires --force alongside --cleanup for non-interactive zap
      extraFlags = [ "--force" ];
    };
    global = {
      brewfile = true;
    };

    brews = [
      "awscli"
      "azure-cli"
      "coreutils"
      "et"
      "gnu-sed"
      "gnu-tar"
      "node"
      "oras"
    ];

    casks = [
      "1password"
      "1password-cli"
      "beekeeper-studio"
      "brave-browser"
      "bruno"
      "capslocknodelay"
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "fork"
      "gcloud-cli"
      "headlamp"
      "kap"
      "knockknock"
      "ghostty"
      "lulu"
      "notunes"
      "obsidian"
      "raycast"
      "signal"
      "slack"
      "spotify"
      "stats"
      "taskexplorer"
      "tailscale-app"
      "microsoft-remote-desktop"
      "orka3"
      "vlc"
      "zed"
    ];
  };

}
