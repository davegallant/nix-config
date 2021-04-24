{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hephaestus"; # Define your hostname.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp34s0.useDHCP = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  # Evolution
  programs.evolution.enable = true;
  programs.evolution.plugins = [ pkgs.evolution-ews ];
  services.gnome3.evolution-data-server.enable = true;
  services.gnome3.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

}

