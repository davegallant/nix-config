{
  config,
  lib,
  master,
  modulesPath,
  pkgs,
  unstable,
  vpngate,
  ...
}:
let
  gnomeExtensions = with pkgs.gnomeExtensions; [
    caffeine
    clipboard-history
    grand-theft-focus
  ];
in
{

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/davegallant/nix-config/refs/heads/main/nixos-wallpaper.png";
      sha256 = "Ztqn9+CHslr6wZdnOTeo/YNi/ICerpcFLyMArsZ/PIY=";
    };
    polarity = "dark";
  };

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  boot = {
    kernelModules = [
      "kvm-amd"
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
      "vfio_virqfd"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
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
        device = "/dev/disk/by-uuid/21cd166c-1528-49a4-b31b-0d408d48aa80";
        preLVM = true;
        keyFile = "./keyfile0.bin";
      };
      secrets = {
        "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
    };
  };

  environment.systemPackages =
    with pkgs;
    [
      bleachbit
      calibre
      chromium
      cryptsetup
      dbeaver-bin
      discord
      freefilesync
      gimp-with-plugins
      gnome-tweaks
      google-chrome
      hardinfo2
      httpie-desktop
      iputils
      kdePackages.kcalc
      kdePackages.kcharselect
      kdePackages.kclock
      kdePackages.kcolorchooser
      kdePackages.ksystemlog
      kdePackages.sddm-kcm
      libation
      mission-center
      mupen64plus
      nfs-utils
      onlyoffice-desktopeditors
      opensnitch-ui
      pavucontrol
      pciutils
      pika-backup
      pinentry-curses
      pinta
      protonvpn-gui
      qemu
      traceroute
      unstable.beszel
      unstable.obsidian
      unstable.podman
      unstable.podman-compose
      unstable.podman-desktop
      unstable.ryubing
      unstable.signal-desktop-bin
      unstable.spotify
      unstable.tailscale
      unstable.zoom-us
      usbutils
      virt-manager
      vlc
      vpngate.packages.x86_64-linux.default
      wayland-utils
      whois
      wine
      wl-clipboard
    ]
    ++ gnomeExtensions;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a6723178-6f18-428e-b541-9ac901861125";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/e3ab2e1a-bddf-4ae0-b00a-bf954c6c182b";
      fsType = "ext4";
    };
    "/boot/efi" = {
      device = "/dev/disk/by-uuid/3CFD-D749";
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

  fonts.packages = with pkgs; [
    dejavu_fonts
    fira-mono
    font-awesome
    google-fonts
    liberation_ttf
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    noto-fonts-extra
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "Noto Sans Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
  };

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
      allowPing = false;
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
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

  system = {
    autoUpgrade.enable = true;
    stateVersion = "25.05";
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
  };

  users.users.dave = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
      "corectrl"
    ];
    shell = pkgs.zsh;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ anthy ];
  };

  time.timeZone = "America/Toronto";

  hardware.bluetooth.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nix-ld.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    zsh.enable = true;
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

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };

  services.flatpak.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.printing.enable = true;

  services.resolved.enable = true;

  services.sshd.enable = true;

  services.tailscale = {
    enable = true;
    package = unstable.tailscale;
  };

  services.xserver = {
    enable = false;
    displayManager = {
      gdm = {
        enable = false;
        wayland = true;
      };
    };
    desktopManager.gnome.enable = false;
    videoDrivers = [ "amdgpu" ];
  };

  services.ollama = {
    package = pkgs.ollama;
    enable = true;
    # acceleration = "rocm";
    host = "0.0.0.0";
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    };
    loadModels = [
      "dolphin3:8b"
      "llama3.1"
      "llava"
    ];
  };

  services.open-webui = {
    enable = true;
    package = pkgs.open-webui;
    host = "0.0.0.0";
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };

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
    podman.enable = true;
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
  };
}
