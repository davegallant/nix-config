{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = ["ntfs"];

  system.stateVersion = "23.05";

  system.autoUpgrade.enable = true;

  systemd.services.tailscaled.after = ["network-online.target" "systemd-resolved.service"];

  nix.extraOptions = "experimental-features = nix-command flakes";
  nix.package = pkgs.nixUnstable;

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
  virtualisation.libvirtd.enable = true;

  virtualisation.podman.enable = true;

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.corectrl.enable = true;
}
