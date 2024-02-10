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
      bitwarden
      chromium
      cryptsetup
      deja-dup
      discord
      docker
      docker-compose
      foliate
      ghostscript
      gimp-with-plugins
      glibcLocales
      gnome.gnome-tweaks
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
      google-cloud-sdk
      iputils
      kazam
      legendary-gl
      lm_sensors
      mullvad-vpn
      netdata
      nfs-utils
      obs-studio
      pavucontrol
      pinentry-curses
      podman
      psst
      qemu
      rustup
      ryujinx
      strace
      tailscale
      traceroute
      unstable.android-studio
      unstable.android-tools
      unstable.obsidian
      unstable.signal-desktop
      unstable.unityhub
      unstable.yuzu
      unstable.zoom-us
      usbutils
      virt-manager
      vlc
      whois
      wine
      wine64
      wireshark-qt
    ];
  in
    linux;

  programs.gnupg.agent.enable = true;
}
