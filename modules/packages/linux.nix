{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) stdenv;
in {
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
      traceroute
    ];
  in
    linux;

  programs.gnupg.agent.enable = true;
}
