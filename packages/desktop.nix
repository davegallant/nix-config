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
      gnome3.gnome-tweaks
      gnomeExtensions.appindicator
      guake
      i3lock-fancy-rapid
      kazam
      keyleds
      nvfancontrol
      pavucontrol
      podman
      qemu
      signal-desktop
      slack
      spotify
      steam
      usbutils
      virtmanager
      vlc
      vscodium
      wireshark-qt
      xautolock
      yaru-theme
      zoom-us
    ];
  in
    linuxDesktop;

  programs.gnupg.agent.enable = true;
}