{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "hephaestus";

  networking = {
    interfaces.enp34s0 = { useDHCP = true; };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp34s0";
    };
  };

  # Enable the OpenSSH server.
  services.sshd.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  # Evolution
  programs.evolution.enable = true;
  programs.evolution.plugins = [ pkgs.evolution-ews ];
  services.gnome.evolution-data-server.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

}

