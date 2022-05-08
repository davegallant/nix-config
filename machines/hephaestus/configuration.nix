{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.nvidia.modesetting.enable = true;
  /* hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470; */

  networking.hostName = "hephaestus";

  networking = {
    interfaces.enp34s0 = {
      useDHCP = true;
      /* ipv4.addresses = [ */
      /*   { */
      /*     address = "192.168.1.69"; */
      /*     prefixLength = 24; */
      /*   } */
      /* ]; */
    };
    defaultGateway = {
      address = "192.168.1.2";
      interface = "enp34s0";
    };
    firewall = {
      allowedTCPPorts = [
        19999 # netdata
      ];
      allowedUDPPorts = [
        41641 # tailscale
      ];
    };
  };

  services.sshd.enable = true;
  services.tailscale = { enable = true; };
  services.xserver.videoDrivers = [ "nvidia" ];
}

