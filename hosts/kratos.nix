{
  lib,
  pkgs,
  unstable,
  ...
}:
{
  features.ai.enable = true;

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  home-manager.users.dave.features = {
    headless.enable = true;
    ai.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "prl-tools" ];

  networking.hostName = "kratos";
  networking.firewall.interfaces.docker0.allowedTCPPorts = [ 4000 ];

  programs.ssh.startAgent = true;

  boot = {
    initrd.availableKernelModules = [
      "ehci_pci"
      "xhci_pci"
      "usbhid"
      "sr_mod"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/mnt/psf/src" = {
    device = "src";
    fsType = "prl_fs";
    options = [
      "nofail"
      "noatime"
      "nodev"
      "nosuid"
    ];
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 512;
    "fs.inotify.max_queued_events" = 32768;
    "vm.max_map_count" = 262144;
    "fs.file-max" = 2097152;
  };

  swapDevices = [ ];

  system.stateVersion = "25.11";

  users.users.dave.extraGroups = [
    "docker"
    "wheel"
  ];

  virtualisation.docker.enable = true;

  hardware.parallels.enable = true;

  services.eternal-terminal.enable = true;
  networking.firewall.allowedTCPPorts = [ 2022 ];
  networking.firewall.extraCommands = ''
    iptables -I DOCKER-USER -s 172.0.0.0/8 -d 192.168.1.0/24 -j DROP
    iptables -I DOCKER-USER -s 172.0.0.0/8 -d 10.0.0.0/8 -j DROP
    iptables -I DOCKER-USER -s 172.0.0.0/8 -d 172.16.0.0/12 -j DROP
  '';

  environment.systemPackages = with pkgs; [
    awscli2
    (azure-cli.withExtensions [ azure-cli-extensions.fzf ])
    ssm-session-manager-plugin
    terraform
  ];

}
