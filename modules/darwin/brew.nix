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
    autoUpdate = false;
    global = {
      brewfile = true;
    };

    brews = [
      "coreutils"
      "fabianishere/personal/pam_reattach"
      "gnu-sed"
      "gnu-tar"
      "netdata"
      "node"
      "universal-ctags"
    ];

    casks = [
      "authy"
      "dbeaver-community"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "lulu"
      "maccy"
      # "osxfuse"
      "rectangle"
      "vscodium"
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
    ];
  };
}
