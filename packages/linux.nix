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
      cpu-x
      cryptsetup
      docker
      docker-compose
      glibcLocales
      lm_sensors
      netdata
      pinentry-curses
      nfs-utils
      rustup
      strace
      tailscale
      unityhub
    ];
  in
    linux;

  programs.gnupg.agent.enable = true;
}
