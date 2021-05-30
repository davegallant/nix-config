{ pkgs, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  nixpkgs.config.allowUnfree = true;

  environment = { variables = { LANG = "en_US.UTF-8"; }; };

  networking = { hostName = "demeter"; };

  system.defaults = {
    NSGlobalDomain = {
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleShowScrollBars = "Automatic";
      AppleTemperatureUnit = "Celsius";
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 10;
      KeyRepeat = 3;
      _HIHideMenuBar = true;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
      tilesize = 512;
    };

    finder = {
      AppleShowAllExtensions = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      TrackpadRightClick = true;
    };

    # Login and lock screen
    loginwindow = { GuestEnabled = false; };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nixFlakes;

  programs.zsh = {
    enable = true;
    # https://github.com/nix-community/home-manager/issues/108#issuecomment-340397178
    enableCompletion = false;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 4;
}
