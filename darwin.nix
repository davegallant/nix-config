{ pkgs, username, ... }:
{
  nix.enable = false;

  system.stateVersion = 4;

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  system.primaryUser = username;

  system.defaults = {
    trackpad = {
      ActuationStrength = 0;
      Clicking = true;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      TrackpadRightClick = true;
    };
    WindowManager = {
      GloballyEnabled = false;
      EnableTilingByEdgeDrag = true;
      EnableTopTilingByEdgeDrag = true;
      EnableTilingOptionAccelerator = true;
      EnableTiledWindowMargins = false;
    };
    NSGlobalDomain = {
      "com.apple.mouse.tapBehavior" = 1;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Always";
      InitialKeyRepeat = 25;
      KeyRepeat = 2;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSUseAnimatedFocusRing = false;
      NSWindowShouldDragOnGesture = true;
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathbar = true;
      _FXShowPosixPathInTitle = true;
      FXPreferredViewStyle = "Nlsv";
    };
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
    global.brewfile = true;

    brews = [
      "coreutils"
      "gnu-sed"
      "gnu-tar"
    ];

    casks = [
      "brave-browser"
      "bruno"
      "capslocknodelay"
      "cyberduck"
      "dbeaver-community"
      "docker-desktop"
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
      "secretive"
      "spotify"
      "stats"
      "taskexplorer"
      "tailscale-app"
      "windows-app"
      "unity-hub"
      "utm"
      "vlc"
      "zed"
    ];
  };
}
