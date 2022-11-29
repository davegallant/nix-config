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
      davinci-resolve
      deluge
      discord
      firefox
      ghostscript
      gimp-with-plugins
      gnome.gnome-tweaks
      gnome.gnome-sound-recorder
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-panel
      gnomeExtensions.notification-banner-reloaded
      gnomeExtensions.openweather
      gnomeExtensions.stocks-extension
      gnomeExtensions.tailscale-status
      gnomeExtensions.vitals
      guake
      kazam
      keyleds
      legendary-gl
      mailspring
      obs-studio
      pavucontrol
      podman
      qemu
      signal-desktop
      slack
      steam-tui
      superTuxKart
      usbutils
      virt-manager
      vlc
      wine64
      wireshark-qt
      yaru-theme
      zoom-us
    ];
  in
    linuxDesktop;

  programs.gnupg.agent.enable = true;
}
