{
  inputs,
  lib,
  pkgs,
  modulesPath,
  pvectl,
  unstable,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../opensnitch.nix
  ];

  home-manager.users.dave.imports = [
    ../home/keepassxc-ssh-agent.nix
    ../home/retroarch.nix
    ../home/ryujinx.nix
  ];

  system.stateVersion = "26.05";

  boot = {
    kernelPackages = pkgs.linuxPackages;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = [
      "ahci"
      "ehci_pci"
      "sd_mod"
      "sr_mod"
      "uhci_hcd"
      "usbhid"
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  # npm-installed tooling runs via nix-ld (nixos.nix)
  environment.systemPackages = with pkgs; [
    # LINE needs a manually-fetched installer added to the store first — see
    # pkgs/line.nix for instructions. Re-add once that's done on apollo:
    # (pkgs.callPackage ../pkgs/line.nix { wine = pkgs.wineWow64Packages.base; })
    (retroarch.withCores (
      cores: with cores; [
        mupen64plus
        snes9x
      ]
    ))
    keepassxc
    pvectl.packages.${pkgs.stdenv.hostPlatform.system}.default
    trayscale
    unstable.signal-desktop
    vim
  ];

  networking = {
    hostName = "apollo";
    hostId = "861d59c4";
    firewall = {
      allowPing = true;
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
    };
    networkmanager.enable = true;
  };

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    gc.dates = "daily";
  };

  users.users.dave.extraGroups = [
    "docker"
    "gamemode"
    "input"
    "libvirtd"
    "networkmanager"
    "plugdev"
    "wheel"
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.keyboard.qmk.enable = true;
  # udev rules for Steam Controller / Xbox / PS / other gamepads
  hardware.steam-hardware.enable = true;

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Apollo is a VM that should never sleep/suspend/hibernate
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    IdleAction = "ignore";
  };

  services.resolved.enable = true;

  services.syncthing = {
    enable = true;
    user = "dave";
    dataDir = "/home/dave";
    configDir = "/home/dave/.config/syncthing";
    openDefaultPorts = true;
    overrideDevices = false;
    overrideFolders = false;
    settings.options.urAccepted = -1;
  };

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
  };
}
