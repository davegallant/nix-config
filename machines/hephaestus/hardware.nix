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
  boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback.out];

  powerManagement.cpuFreqGovernor = "balanced";

  boot.initrd.luks.devices = {
    luksroot = {
      allowDiscards = true;
      device = "/dev/disk/by-uuid/570a2b97-3310-4784-9138-6e09037cea17";
      preLVM = true;
    };

    luksstorage = {
      allowDiscards = true;
      device = "/dev/disk/by-uuid/23b54f60-1eb8-4bf1-b04c-79f8537c228a";
      preLVM = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8cfaf3d2-1cae-48b0-a37b-6c192f0b2680";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2368-A8CE";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/aca92a73-2941-40ca-88c4-0dd8607d232a";}];

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/0f592fca-1d4e-43f7-9bf4-f1c3e19e841f";
    fsType = "ext4";
  };
  hardware.video.hidpi.enable = lib.mkDefault true;
}
