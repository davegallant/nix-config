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
      "azure-cli"
      "coreutils"
      "gnu-sed"
      "gnu-tar"
      "netdata"
      "node"
      "podman"
    ];

    casks = [
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "karabiner-elements"
      "lulu"
      "raycast"
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
