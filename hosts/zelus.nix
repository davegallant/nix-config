{ pkgs, ... }:
{
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
        "/Applications/ghostty.app"
        "/Applications/Google Chrome.app"
        "/Applications/Brave Browser.app"
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

  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = false;
        mouse_follows_focus = false;
        preset_column_widths = [
          0.5
          1
        ];
      };
      bindings = {
        window_focus_west = "cmd - leftarrow";
        window_focus_east = "cmd - rightarrow";
        window_swap_west = "cmd + shift - leftarrow";
        window_swap_east = "cmd + shift - rightarrow";
        window_resize = "alt - r";
        window_center = "alt - c";
        window_fullwidth = "cmd - return";
        window_manage = "alt - t";
        quit = "ctrl + alt - q";
      };
    };
  };

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
      "peon-ping"
      "python@3.14"
      "vault"
    ];

    casks = [
      "brave-browser"
      "capslocknodelay"
      "discord"
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "fork"
      "headlamp"
      "iterm2"
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
      "steam"
      "taskexplorer"
      "tailscale-app"
      "vlc"
      "whisky"
      "zed"
    ];

    taps = [
      "hashicorp/tap"
      "PeonPing/tap"
    ];
  };

}
