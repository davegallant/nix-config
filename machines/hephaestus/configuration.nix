{
  config,
  pkgs,
  ...
}: {
  imports = [./hardware.nix];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  networking = {
    hostName = "hephaestus";
    interfaces.enp34s0 = {
      useDHCP = true;
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
  services.tailscale = {enable = true;};
  services.xserver = {
    videoDrivers = ["nvidia"];
    deviceSection = ''
      Option    "Coolbits" "4"
    '';
    exportConfiguration = true;
  };

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
  '';
}
