{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  unstable,
  ...
}:
{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

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
      extraCommands = ''
        iptables -I DOCKER-USER -s 172.0.0.0/8 -d 192.168.1.0/24 -j DROP
        iptables -I DOCKER-USER -s 172.0.0.0/8 -d 10.0.0.0/8 -j DROP
        iptables -I DOCKER-USER -s 172.0.0.0/8 -d 172.16.0.0/12 -j DROP
      '';
    };
  };

  users.users.beszel = {
    isSystemUser = true;
    group = "beszel";
    description = "Beszel Agent service user";
  };
  users.groups.beszel = { };

  systemd.services = {
    NetworkManager-wait-online.enable = false;

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

  services.ollama = {
    package = unstable.ollama-rocm;
    enable = true;
    acceleration = "rocm";
    host = "0.0.0.0";
    rocmOverrideGfx = "11.0.2";
  };

  system.stateVersion = "25.11";

  nix = {
    settings = {
      auto-optimise-store = true;
      substituters = [ "https://davegallant.cachix.org" ];
      trusted-public-keys = [
        "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08="
      ];
    };
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

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-anthy
      fcitx5-gtk
    ];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  hardware.keyboard.qmk.enable = true;

  services.udev.extraRules = ''
    # Prevent epomaker TH85's extra HID interfaces from being detected as joystick/gamepad
    ATTRS{idVendor}=="36b0", ATTRS{idProduct}=="3002", \
    ENV{ID_INPUT_JOYSTICK}="", ENV{ID_INPUT_ACCELEROMETER}=""
  '';

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  documentation.man.generateCaches = false;

  programs = {
    nix-ld.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.niri.default = [
      "gnome"
      "gtk"
    ];
    config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ]; # skip nautilus

  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  services.printing.enable = true;

  services.resolved.enable = true;

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;

  services.opensnitch = {
    enable = true;
    rules = {
      avahi-ipv4 = {
        name = "Allow avahi daemon IPv4";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              operand = "process.path";
              sensitive = false;
              data = "${lib.getBin pkgs.avahi}/bin/avahi-daemon";
            }
            {
              type = "network";
              operand = "dest.network";
              data = "224.0.0.0/24";
            }
          ];
        };
      };
      systemd-timesyncd = {
        name = "systemd-timesyncd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd";
        };
      };
      systemd-resolved = {
        name = "systemd-resolved";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "simple";
          sensitive = false;
          operand = "process.path";
          data = "${lib.getBin pkgs.systemd}/lib/systemd/systemd-resolved";
        };
      };
      localhost = {
        name = "Allow all localhost";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "regexp";
          operand = "dest.ip";
          sensitive = false;
          data = "^(127\\.0\\.0\\.1|::1)$";
          list = [ ];
        };
      };
      nix-update = {
        name = "Allow Nix";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.nix}/bin/nix";
            }
            {
              type = "regexp";
              operand = "dest.host";
              sensitive = false;
              data = "^(([a-z0-9|-]+\\.)*github\\.com|([a-z0-9|-]+\\.)*nixos\\.org)$";
            }
          ];
        };
      };
      NetworkManager = {
        name = "Allow NetworkManager";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.networkmanager}/bin/NetworkManager";
            }
            {
              type = "simple";
              operand = "dest.port";
              sensitive = false;
              data = "67";
            }
            {
              type = "simple";
              operand = "protocol";
              sensitive = false;
              data = "udp";
            }
          ];
        };
      };
      ssh-github = {
        name = "Allow SSH to github";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type = "list";
          operand = "list";
          list = [
            {
              type = "simple";
              sensitive = false;
              operand = "process.path";
              data = "${lib.getBin pkgs.openssh}/bin/ssh";
            }
            {
              type = "simple";
              operand = "dest.host";
              sensitive = false;
              data = "github.com";
            }
          ];
        };
      };
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
  };
}
