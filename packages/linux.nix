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
    linux = [
      cryptsetup
      docker
      docker-compose
      rfd
      glibcLocales
      iotop
      linuxPackages.perf
      netdata
      pinentry-curses
      rustup
      strace
      tailscale
    ];
  in
    linux;

  programs.gnupg.agent.enable = true;
}
