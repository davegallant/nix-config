{
  lib,
  unstable,
  ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "prl-tools" ];

  networking.hostName = "kratos";

  boot = {
    initrd.availableKernelModules = [
      "ehci_pci"
      "xhci_pci"
      "usbhid"
      "sr_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/mnt/psf/Home" = {
    device = "Home";
    fsType = "prl_fs";
    options = [ "nofail" ];
  };

  swapDevices = [ ];

  system.stateVersion = "25.11";

  users.users.dave.extraGroups = [
    "docker"
    "wheel"
  ];

  virtualisation.docker.enable = true;

  hardware.graphics.enable = true;
  hardware.parallels.enable = true;

  services.libinput.enable = true;

  environment.systemPackages = [
    unstable.azure-cli
    unstable.claude-code
  ];

  services.opensnitch.enable = true;
}
