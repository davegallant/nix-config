{ lib, pkgs, ... }:
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      gnome-calculator
      kodi
      moonlight-qt
      pwvucontrol
      wl-clipboard
      xclip
      xdg-utils
    ];

    xdg.configFile."kscreenlockerrc".text = ''
      [Daemon]
      Autolock=false
      LockOnResume=false
    '';
  };
}
