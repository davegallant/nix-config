{
  config,
  lib,
  pkgs,
  ...
}: let
  checkBrew = "command -v brew > /dev/null";
in {
  environment = {
    extraInit = ''
      ${checkBrew} || >&2 echo "brew is not installed (install it via https://brew.sh)"
    '';
  };

  homebrew = {
    enable = true;
    onActivation.autoUpdate = false;
    onActivation.upgrade = false;
    global = {
      brewfile = true;
    };

    brews = [
      "bensadeh/circumflex/circumflex"
      "bicep"
      "coreutils"
      "gnu-sed"
      "gnu-tar"
      "netdata"
      "node"
      "podman"
      "universal-ctags"
    ];

    casks = [
      "alfred"
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "karabiner-elements"
      "lulu"
      "maccy"
      "notunes"
      "postman"
      "rectangle"
      "stats"
      "visual-studio-code"
    ];

    taps = [
      "azure/bicep"
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
    ];
  };
}
