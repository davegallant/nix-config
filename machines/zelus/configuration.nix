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

  programs.zsh = {
    enable = true;
    # https://github.com/nix-community/home-manager/issues/108#issuecomment-340397178
    enableCompletion = false;
  };

  system.stateVersion = 4;

  users.users."dave.gallant".home = "/Users/dave.gallant";

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
        "/Applications/Ghostty.app"
        "/Applications/Google Chrome.app"
        "/Applications/LibreWolf.app"
        "/Applications/Logseq.app"
        "/Applications/Slack.app"
        "/Applications/Spotify.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/zoom.us.app"
      ];
    };

    NSGlobalDomain = {
      "com.apple.sound.beep.feedback" = 0;
      "com.apple.sound.beep.volume" = 0.0;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 10;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Automatic";
    };
  };

  security.pam.enableSudoTouchIdAuth = true;

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
      "azure-cli"
      "coreutils"
      "gnu-sed"
      "gnu-tar"
      "netdata"
      "node"
      "oras"
      "k6"
    ];

    casks = [
      "discord"
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "fork"
      "ghostty"
      "iterm2"
      "karabiner-elements"
      "knockknock"
      "librewolf"
      "logseq"
      "lulu"
      "mitmproxy"
      "notunes"
      "ollama"
      "postman"
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
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
    ];
  };

  stylix = {
    # enable = true;
    image = "/Library/tokyo-night.jpg";
  };

}
