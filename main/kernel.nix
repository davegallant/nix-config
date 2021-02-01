{ pkgs, ... }:

{
  # Use the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable support for additional filesystems
  boot.supportedFilesystems = [ "ntfs" ];
}
