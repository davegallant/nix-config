{ pkgs, unstable, ... }:
{
  networking = {
    hostName = "helios";
  };

  nix.enable = false;

  system.stateVersion = 4;

  users.users."dave".home = "/Users/dave";
  users.users."dave".shell = pkgs.fish;

  programs.fish.enable = true;

  system.primaryUser = "dave";
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
        "/Applications/Brave Browser.app"
        "/Applications/Obsidian.app"
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
      "coreutils"
      "et"
      "gnu-sed"
      "gnu-tar"
    ];

    casks = [
      "brave-browser"
      "bruno"
      "capslocknodelay"
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "fork"
      "kap"
      "knockknock"
      "ghostty"
      "lulu"
      "notunes"
      "obsidian"
      "raycast"
      "signal"
      "spotify"
      "stats"
      "taskexplorer"
      "tailscale-app"
      "microsoft-remote-desktop"
      "vlc"
      "zed"
    ];
  };

}
