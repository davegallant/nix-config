{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.luksroot = {
    allowDiscards = true;
    device = "/dev/disk/by-uuid/570a2b97-3310-4784-9138-6e09037cea17";
    preLVM = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8cfaf3d2-1cae-48b0-a37b-6c192f0b2680";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2368-A8CE";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/aca92a73-2941-40ca-88c4-0dd8607d232a"; }];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

}
