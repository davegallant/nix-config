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
      cpu_x
      cryptsetup
      docker
      docker-compose
      glibcLocales
      iotop
      linuxPackages.perf
      netdata
      rfd
      pinentry-curses
      rustup
      strace
      tailscale
    ];
  in
    linux;

  programs.gnupg.agent.enable = true;
}
