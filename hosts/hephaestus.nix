{
  config,
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
{

  features = {
    desktop.enable = true;
    ai = {
      enable = true;
      ollama.enable = true;
    };
  };

  home-manager.users.dave.features = {
    desktop.enable = true;
    ai.enable = true;
  };

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

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
        keyFile = "./keyfile0.bin";
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7f4f0948-041c-47e9-ab28-53132026f158";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/F1BD-5227";
      fsType = "vfat";
    };
    "/mnt/synology-2b/media" = {
      device = "192.168.1.178:/volume1/Media";
      fsType = "nfs";
    };
    "/mnt/truenas/home/backups" = {
      device = "192.168.1.132:/mnt/wd4t/data/home/backup/";
      fsType = "nfs";
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    iproute2.enable = true;
    hostName = "hephaestus";
    hostId = "0e8aad53";
    interfaces."enp34s0" = {
      useDHCP = true;
      wakeOnLan = {
        enable = true;
        policy = [ "magic" ];
      };
    };
    firewall = {
      allowPing = true;
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      interfaces.docker0.allowedTCPPorts = [ 4000 ];
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

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  system.stateVersion = "25.11";

  nix = {
    settings.auto-optimise-store = true;
    registry.nixpkgs.flake = inputs.nixpkgs;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };

  users.users.dave.extraGroups = [
    "docker"
    "libvirtd"
    "wheel"
    "input"
    "plugdev"
  ];

  hardware.keyboard.qmk.enable = true;

  services.udev.extraRules = ''
    # Prevent epomaker TH85's extra HID interfaces from being detected as joystick/gamepad
    ATTRS{idVendor}=="36b0", ATTRS{idProduct}=="3002", \
    ENV{ID_INPUT_JOYSTICK}="", ENV{ID_INPUT_ACCELEROMETER}=""
  '';

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
