{ unstable, ... }:

{
  # Use the latest kernel
  boot.kernelPackages = unstable.linuxPackages_latest;

  # Enable support for additional filesystems
  boot.supportedFilesystems = [ "ntfs" ];
}
