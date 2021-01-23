{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.luksroot = {
    device = "/dev/disk/by-uuid/4b886807-3e19-437c-84bb-c2dd766fc19b";
    allowDiscards = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/48d2e958-00a0-47fa-8c32-9aec031f6098";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D387-B640";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/92c35fa7-2d2e-4172-abaf-4c81599782f1"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
