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
    linux = [
      albert
      bitwarden
      bitwarden-cli
      chromium
      cpu-x
      cryptsetup
      deja-dup
      discord
      docker
      docker-compose
      foliate
      ghostscript
      gimp-with-plugins
      glibcLocales
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
      lm_sensors
      netdata
      nfs-utils
      obs-studio
      pavucontrol
      pinentry-curses
      podman
      prismlauncher
      psst
      qemu
      rustup
      ryujinx
      steam-tui
      strace
      traceroute
      unstable.obsidian
      unstable.signal-desktop
      unstable.tailscale
      unstable.unityhub
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
    linux;

  programs.gnupg.agent.enable = true;
}
