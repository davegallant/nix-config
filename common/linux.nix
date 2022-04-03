{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = [ "ntfs" ];

  system.stateVersion = "unstable";
  system.autoUpgrade.enable = true;

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixUnstable;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-9.4.4" # authy is currently stuck on electron_9
    ];
  };

  users.users.dave = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "libvirtd" ];
    shell = pkgs.zsh;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "America/Toronto";

  sound.enable = true;

  # Enable 32bit for steam
  hardware.pulseaudio.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

}
