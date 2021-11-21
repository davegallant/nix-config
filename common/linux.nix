{ pkgs, ... }:

{
  system.stateVersion = "unstable";
  system.autoUpgrade.enable = true;

  # Automatically optimize the Nix store.
  nix.autoOptimiseStore = true;

  # Enable Nix flake support.
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = "experimental-features = nix-command flakes";

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-9.4.4"
    ];
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Enable support for additional filesystems
  boot.supportedFilesystems = [ "ntfs" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dave = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Enable 32bit for steam
  hardware.pulseaudio.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  virtualisation.podman.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

}
