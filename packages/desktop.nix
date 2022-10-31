{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) stdenv;
in {
  # System-wide packages to install.
  environment.systemPackages = with pkgs; let
    linuxDesktop = [
      albert
      authy
      bitwarden
      brave
      calibre
      deluge
      discord
      firefox
      ghostscript
      gimp-with-plugins
      gnome.gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-panel
      gnomeExtensions.openweather
      /*
       gnomeExtensions.stocks-extension
       */
      gnomeExtensions.tailscale-status
      gnomeExtensions.vitals
      guake
      kazam
      keyleds
      pavucontrol
      podman
      qemu
      signal-desktop
      slack
      spotify
      steam-tui
      usbutils
      virt-manager
      vlc
      wireshark-qt
      yaru-theme
      zoom-us
    ];
  in
    linuxDesktop;

  programs.gnupg.agent.enable = true;
}
