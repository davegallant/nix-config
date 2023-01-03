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
      gnome.gnome-sound-recorder
      gnome.gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-panel
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.notification-banner-reloaded
      gnomeExtensions.openweather
      gnomeExtensions.tailscale-status
      gnomeExtensions.vitals
      google-cloud-sdk
      guake
      kazam
      legendary-gl
      mailspring
      prismlauncher
      obs-studio
      pavucontrol
      podman
      qemu
      signal-desktop
      steam-tui
      superTuxKart
      usbutils
      virt-manager
      vlc
      wine64
      wireshark-qt
      yaru-theme
      yuzu
      zoom-us
    ];
  in
    linuxDesktop;

  programs.gnupg.agent.enable = true;
}
