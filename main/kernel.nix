{ pkgs, ... }:

{
  # Use the latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable support for additional filesystems
  boot.supportedFilesystems = [ "ntfs" ];
}
