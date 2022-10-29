{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = ["ntfs"];

  system.stateVersion = "unstable";
  system.autoUpgrade.enable = true;

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixUnstable;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [];
  };

  users.users.dave = {
    isNormalUser = true;
    extraGroups = ["docker" "wheel" "libvirtd" "corectrl"];
    shell = pkgs.zsh;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "America/Toronto";

  sound.enable = true;

  services.opensnitch.enable = true;

  hardware.pulseaudio.enable = true;

  # Enable Vulkan
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable Steam
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [libva];
  hardware.pulseaudio.support32Bit = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.libvirtd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.corectrl.enable = true;
}
