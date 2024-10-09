{ pkgs, ... }:
let checkBrew = "command -v brew > /dev/null";
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };

  networking = { hostName = "zelus"; };

  services.nix-daemon.enable = true;

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixVersions.stable;

  programs.zsh = {
    enable = true;
    # https://github.com/nix-community/home-manager/issues/108#issuecomment-340397178
    enableCompletion = false;
  };

  system.stateVersion = 4;
  users.users."dave.gallant".home = "/Users/dave.gallant";

  environment = {
    extraInit = ''
      ${checkBrew} || >&2 echo "brew is not installed (install it via https://brew.sh)"
    '';
    variables = { LANG = "en_US.UTF-8"; };
  };

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
      autohide-delay = 0.0;
      autohide-time-modifier = 1.0;
      tilesize = 50;
      static-only = false;
      showhidden = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      mru-spaces = false;
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

  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;
    global = { brewfile = true; };

    brews = [
      "azure-cli"
      "coreutils"
      "gnu-sed"
      "gnu-tar"
      "netdata"
      "node"
      "podman"
      "podman-compose"
    ];

    casks = [
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "karabiner-elements"
      "iterm2"
      "librewolf"
      "logseq"
      "lulu"
      "notunes"
      "postman"
      "raycast"
      "rectangle"
      "stats"
      "warp"
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
