{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "sd_mod"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    xpadneo
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.initrd = {
    luks.devices."root" = {
      allowDiscards = true;
      device = "/dev/disk/by-uuid/21cd166c-1528-49a4-b31b-0d408d48aa80";
      preLVM = true;
      keyFile = "./keyfile0.bin";
    };
    secrets = {
      "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
    };
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a6723178-6f18-428e-b541-9ac901861125";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/e3ab2e1a-bddf-4ae0-b00a-bf954c6c182b";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/3CFD-D749";
    fsType = "vfat";
  };

  fileSystems."/mnt/synology-2b/media" = {
    device = "192.168.1.178:/volume1/Media";
    fsType = "nfs";
  };

  fileSystems."/mnt/synology-2b/backups" = {
    device = "192.168.1.178:/volume1/Backups";
    fsType = "nfs";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/5d6d0388-2b15-4ff1-9f0f-391818a76090";}
  ];
}
