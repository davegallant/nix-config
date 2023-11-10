{
  config,
  lib,
  pkgs,
  unstable,
  ...
}: let
  inherit (pkgs) stdenv;
in {
  environment.systemPackages = with pkgs; let
    linuxDesktop = [
      albert
      bitwarden
      bitwarden-cli
      chromium
      deja-dup
      discord
      foliate
      ghostscript
      gimp-with-plugins
      gnome.gnome-sound-recorder
      gnome.gnome-tweaks
      gnome.seahorse
      gnomeExtensions.appindicator
      gnomeExtensions.bluetooth-quick-connect
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      gnomeExtensions.grand-theft-focus
      gnomeExtensions.notification-banner-reloaded
      gnomeExtensions.quick-settings-tweaker
      gnomeExtensions.tailscale-status
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.vitals
      google-cloud-sdk
      
      kazam
      legendary-gl
      obs-studio
      pavucontrol
      podman
      prismlauncher
      psst
      qemu
      ryujinx
      steam-tui
      unstable.signal-desktop
      unstable.yuzu
      unstable.zoom-us
      usbutils
      virt-manager
      vlc
      wine
      wine64
      wireshark-qt
      yaru-theme
    ];
  in
    linuxDesktop;

  programs.gnupg.agent.enable = true;
}
