{ config, lib, pkgs, ... }:

let
  checkBrew = "command -v brew > /dev/null";
in
{
  environment = {
    extraInit = ''
      ${checkBrew} || >&2 echo "brew is not installed (install it via https://brew.sh)"
    '';
  };

  homebrew = {
    enable = true;
    autoUpdate = true;
    global = {
      brewfile = true;
      noLock = true;
    };

    brews = [
      "aws-sam-cli"
      "coreutils"
      "fabianishere/personal/pam_reattach"
      "gnu-sed"
      "gnu-tar"
      "netdata"
      "node"
      "rewindio/public/aws-role-play"
      "universal-ctags"
    ];

    casks = [
      "1password"
      "amethyst"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "lulu"
      "osxfuse"
      "rectangle"
      "visual-studio-code"
    ];

    taps = [
      "aws/tap"
      "homebrew/bundle"
      "homebrew/cask"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
    ];

  };
}
