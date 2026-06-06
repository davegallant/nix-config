{
  config,
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
{
  imports = [
    ../opensnitch.nix
  ];

  system.stateVersion = "26.05";

  boot = {
    kernelModules = [
      "kvm-amd"
    ];
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [
      "amd_iommu=on"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        enableCryptodisk = true;
      };
    };

    supportedFilesystems = [
      "ntfs"
    ];

    initrd = {
      availableKernelModules = [
        "ahci"
        "nvme"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      luks.devices."root" = {
        allowDiscards = true;
        device = "/dev/disk/by-uuid/89a14ac5-7723-4a0a-bb95-fb2fb2e92160";
        preLVM = true;
        keyFile = "/keyfile0.bin";
      };
      secrets."/keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };
    "/mnt/synology-2b/backups" = {
      device = "192.168.1.178:/volume1/Backups";
      fsType = "nfs";
      options = [
        "nofail"
        "x-systemd.automount"
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    iproute2.enable = true;
    hostName = "hephaestus";
    hostId = "0e8aad53";
    interfaces."enp34s0" = {
      useDHCP = true;
    };
    firewall = {
      allowPing = true;
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
    };
    networkmanager = {
      enable = true;
      unmanaged = [ "enp40s0" ];
    };
  };

  users.users.beszel = {
    isSystemUser = true;
    group = "beszel";
    description = "Beszel Agent service user";
  };
  users.groups.beszel = { };

  systemd.services = {
    beszel-agent = {
      description = "Beszel Agent Service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Environment = [
          "PORT=45876"
          ''KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEaNtnkc+3+fJU+bTO6fibID9FHgFjei0sjJNqvcYtG8"''
        ];
        ExecStart = "${lib.getBin unstable.beszel}/bin/beszel-agent";
        User = "beszel";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };

  services.opensnitch.rules = {
    beszel-agent = {
      name = "Allow beszel agent";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        type = "simple";
        sensitive = false;
        operand = "process.path";
        data = "${lib.getBin unstable.beszel}/bin/beszel-agent";
      };

    };
  };

  nix = {
    registry.nixpkgs.flake = inputs.nixpkgs;
    # nixos.nix sets automatic/options as defaults; only override the cadence
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

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  hardware.keyboard.qmk.enable = true;

  services.udev.extraRules = ''
    # Prevent epomaker TH85's extra HID interfaces from being detected as joystick/gamepad
    ATTRS{idVendor}=="36b0", ATTRS{idProduct}=="3002", \
    ENV{ID_INPUT_JOYSTICK}="", ENV{ID_INPUT_ACCELEROMETER}=""
  '';

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  services.resolved.enable = true;

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
