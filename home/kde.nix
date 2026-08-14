{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      gnome-calculator
      kodi
      moonlight-qt
      kdePackages.plasma-browser-integration
      pwvucontrol
      python3
      wl-clipboard
      xclip
      xdg-utils
    ];

    xdg.configFile."kscreenlockerrc".text = ''
      [Daemon]
      Autolock=true
      LockOnResume=false
      Timeout=5
    '';
  };
}
