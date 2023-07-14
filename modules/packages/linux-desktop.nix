{
  config,
  lib,
  pkgs,
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
      fx_cast_bridge
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
      gnomeExtensions.grand-theft-focus
      gnomeExtensions.notification-banner-reloaded
      gnomeExtensions.quick-settings-tweaker
      gnomeExtensions.tailscale-status
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.vitals
      google-cloud-sdk
      kazam
      legendary-gl
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
      yaru-theme
      yuzu
      zoom-us
    ];
  in
    linuxDesktop;

  programs.gnupg.agent.enable = true;
}
