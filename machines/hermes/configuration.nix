{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hermes";

  networking.interfaces.wlp61s0.useDHCP = true;

  services.power-profiles-daemon.enable = false;

}

