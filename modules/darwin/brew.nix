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
      "gnu-sed"
      "gnu-tar"
      "fabianishere/personal/pam_reattach"
      "netdata"
    ];

    casks = [
      "1password"
      "amethyst"
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
      "osxfuse"
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
