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

  networking.hostName = "kratos";
  networking.hosts = {
    "192.168.64.1" = [ "ares" ];
  };
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

  services.tailscale.enable = lib.mkForce false;

  services.eternal-terminal.enable = true;
  networking.firewall.allowedTCPPorts = [ 2022 ];

  # Trust the UTM shared-network interface so ad-hoc dev ports
  # (kubectl port-forward, vite, etc.) are reachable from ares without
  # opening them to the world.
  networking.firewall.trustedInterfaces = [ "enp0s1" ];

  # Certain VPNs add encapsulation overhead, and GitHub's servers are strict about oversized packets
  networking.interfaces.enp0s1.mtu = 1280;

  environment.systemPackages = with pkgs; [
    awscli2
    (unstable.azure-cli.withExtensions [
      unstable.azure-cli-extensions.bastion
      unstable.azure-cli-extensions.fzf
    ])
    kubelogin
    ssm-session-manager-plugin
    terraform
    vault
  ];

}
