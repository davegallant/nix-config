{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
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
    version = 2;
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
  hardware.video.hidpi.enable = lib.mkDefault true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a6723178-6f18-428e-b541-9ac901861125";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/3CFD-D749";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/5d6d0388-2b15-4ff1-9f0f-391818a76090";}
  ];
}
