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
      android-tools
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
      podman-compose
      psst
      qemu
      rustup
      ryujinx
      signal-desktop
      strace
      tailscale
      traceroute
      unstable.obsidian
      unstable.logseq
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
