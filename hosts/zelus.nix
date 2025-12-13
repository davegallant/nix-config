{ pkgs, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  networking = {
    hostName = "zelus";
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
        "/Applications/iTerm.app"
        "/Applications/Google Chrome.app"
        "/Applications/LibreWolf.app"
        "/Applications/Obsidian.app"
        "/Applications/Slack.app"
        "/Applications/zoom.us.app"
      ];
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
    };
    global = {
      brewfile = true;
    };

    brews = [
      "argocd"
      "azure-cli"
      "coreutils"
      "gnu-sed"
      "gnu-tar"
      "k6"
      "node"
      "oras"
      "vault"
    ];

    casks = [
      "claude-code"
      "discord"
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "fork"
      "freelens"
      "iterm2"
      "karabiner-elements"
      "knockknock"
      "librewolf"
      "lulu"
      "notunes"
      "obsidian"
      "raycast"
      "rectangle"
      "signal"
      "slack"
      "spotify"
      "stats"
      "steam"
      "taskexplorer"
      "tailscale"
      "vlc"
      "zed"
    ];

    taps = [
      "hashicorp/tap"
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
    ];
  };

  stylix = {
    enable = true;
    image = "/Library/tokyo-night.jpg";
  };

}
