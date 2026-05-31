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

  features = {
    desktop.enable = true;
    ai = {
      enable = true;
      ollama.enable = true;
    };
  };

  system.stateVersion = "26.05";

  home-manager.users.dave.features = {
    desktop.enable = true;
    ai.enable = true;
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
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };
    "/mnt/synology-2b/media" = {
      device = "192.168.2.2:/volume1/Media";
      fsType = "nfs";
      options = [
        "nofail"
        "x-systemd.automount"
      ];
    };
    "/mnt/synology-2b/backups" = {
      device = "192.168.2.2:/volume1/Backups";
      fsType = "nfs";
      options = [
        "nofail"
        "x-systemd.automount"
      ];
    };
    "/mnt/hermes" = {
      device = "192.168.1.83:/mnt/pool";
      fsType = "nfs";
      options = [
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "_netdev"
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
      wakeOnLan = {
        enable = true;
        policy = [ "magic" ];
      };
    };
    # For printer
    interfaces."wlp42s0f3u1".ipv4.routes = [
      {
        address = "192.168.18.7";
        prefixLength = 32;
        options = {
          scope = "link";
        };
      }
    ];
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

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  services.opensnitch.rules = {
    mullvad-daemon = {
      name = "Allow mullvad daemon";
      enabled = true;
      action = "allow";
      duration = "always";
      operator = {
        type = "simple";
        sensitive = false;
        operand = "process.path";
        data = "${lib.getBin pkgs.mullvad-vpn}/bin/mullvad-daemon";
      };
    };
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
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };

  users.users.dave.extraGroups = [
    "docker"
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

  systemd.network = {
    enable = true;
    networks."10-enp40s0" = {
      matchConfig.Name = "enp40s0";
      address = [ "192.168.2.1/24" ];
      linkConfig.RequiredForOnline = "no";
    };
  };

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
