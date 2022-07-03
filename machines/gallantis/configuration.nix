{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
with lib; let
  nixos-wsl = import ./nixos-wsl;
in {
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    nixos-wsl.nixosModules.wsl
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "unstable";

  networking = {hostName = "gallantis";};

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "dave";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop
    docker.enable = true;

    tailscale.enable = true;
  };

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
