{ pkgs, username, ... }:
{
  # nix-darwin doesn't manage nix.conf (Determinate Nix owns it), so the
  # `nix.settings.substituters` in nixos.nix never reach macOS. After a fresh
  # install, add the cachix caches manually to /etc/nix/nix.custom.conf:
  #   extra-substituters = https://davegallant.cachix.org https://nix-community.cachix.org
  #   extra-trusted-public-keys = davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
  #   cores = 0
  nix.enable = false;

  # nix-darwin 26.05 dropped the `nix.gc.*` options entirely, and Determinate
  # Nix doesn't schedule collection itself, so run it on a weekly launchd
  # timer. Mirrors the NixOS side (`nixos.nix`: weekly, --delete-older-than 14d).
  # Uses the Determinate-installed binary directly rather than pkgs.nix to
  # avoid version drift with the managing installer.
  launchd.daemons.nix-gc = {
    script = ''
      /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 14d
    '';
    serviceConfig = {
      StartCalendarInterval = [
        {
          Weekday = 0; # Sunday
          Hour = 3;
          Minute = 0;
        }
      ];
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };

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
      upgrade = false;
      # Homebrew 4.x requires --force alongside --cleanup for non-interactive zap
      extraFlags = [ "--force" ];
    };
    global.brewfile = true;

    casks = [
      "boop"
      "coteditor"
      "brave-browser"
      "bruno"
      "capslocknodelay"
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
      "obs"
      "obsidian"
      "secretive"
      "spotify"
      "taskexplorer"
      "windows-app"
      "unity-hub"
      "utm"
      "vlc"
    ];
  };
}
