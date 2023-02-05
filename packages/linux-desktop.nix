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
      discord
      firefox
      ghostscript
      # gimp-with-plugins
      gnome.gnome-sound-recorder
      gnome.gnome-tweaks
      gnome.seahorse
      gnomeExtensions.appindicator
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.grand-theft-focus
      gnomeExtensions.night-theme-switcher
      gnomeExtensions.notification-banner-reloaded
      gnomeExtensions.openweather
      gnomeExtensions.quick-settings-tweaker
      gnomeExtensions.tailscale-status
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.vitals
      gnomeExtensions.just-perfection
      google-cloud-sdk
      kazam
      legendary-gl
      mailspring
      prismlauncher
      obs-studio
      pavucontrol
      podman
      qemu
      ryujinx
      signal-desktop
      steam-tui
      usbutils
      virt-manager
      vlc
      wine
      wine64
      wireshark-qt
      xorg.xmodmap
      yaru-theme
      yuzu
      zoom-us
    ];
  in
    linuxDesktop;

  programs.gnupg.agent.enable = true;
}
