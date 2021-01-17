{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d3079c84-11b2-4c2b-bf9e-5a067854a21d";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CEF0-328B";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/39a775f9-e5b8-4029-875a-1df6d99cad5c"; }];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  # Enable g810-led and set profile.
  # hardware.g810-led.enable = true;
  # hardware.g810-led.profile = builtins.toFile "g610-led-profile" ''
  #   a ff3000 # Set all keys to orange-red.
  #   c # Commit changes.
  # '';

}
