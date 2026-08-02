{ lib, pkgs, ... }:
let
  # Manually pinned to the CraigBorrows/claude-usage-widget main branch HEAD
  # (no tagged releases exist upstream). Bump rev/hash by hand when needed.
  claude-usage-widget = pkgs.fetchFromGitHub {
    owner = "CraigBorrows";
    repo = "claude-usage-widget";
    rev = "5421a14255ceec29ceadc40e805bbf80697b26b4";
    hash = "sha256-XKhYb+SdtXFczVtgZkp4ZweYYW7OgTPr72zgiPq/Gmk=";
  };
in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      gnome-calculator
      kodi
      moonlight-qt
      pwvucontrol
      python3
      wl-clipboard
      xclip
      xdg-utils
    ];

    # A single directory symlink, not recursive = true: KPackage's
    # path-traversal guard canonicalizes each file and rejects anything whose
    # real path escapes the package root, which recursive per-file symlinks
    # into the Nix store would trigger.
    xdg.dataFile."plasma/plasmoids/com.cbo.claudeusage".source = "${claude-usage-widget}/package";

    xdg.configFile."kscreenlockerrc".text = ''
      [Daemon]
      Autolock=false
      LockOnResume=false
    '';
  };
}
