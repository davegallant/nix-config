{
  config,
  lib,
  modulesPath,
  pkgs,
  unstable,
  master,
  ...
}:
let
  gnomeExtensions = with pkgs.gnomeExtensions; [
    appindicator
    bluetooth-quick-connect
    blur-my-shell
    caffeine
    grand-theft-focus
    notification-banner-reloaded
    quick-settings-tweaker
    tailscale-status
    tray-icons-reloaded
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
    fonts.sizes.desktop = 24;
  };

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      xpadneo # Advanced Linux Driver for Xbox One Wireless Controller
    ];
    kernelModules = [ "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages;

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

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages =
    with pkgs;
    [
      albert
      android-studio
      android-tools
      bleachbit
      blender
      calibre
      cryptsetup
      discord
      docker
      docker-compose
      freefilesync
      ghostscript
      gimp-with-plugins
      glibcLocales
      httpie-desktop
      gnome-tweaks
      google-chrome
      iputils
      kazam
      libation
      lm_sensors
      logseq
      mission-center
      mitmproxy
      netdata
      nfs-utils
      onlyoffice-desktopeditors
      opensnitch-ui
      pavucontrol
      pika-backup
      pinentry-curses
      podman
      protonvpn-gui
      qemu
      ryujinx
      strace
      traceroute
      unityhub
      unstable.burpsuite
      unstable.dotnet-sdk_8
      unstable.ghostty
      unstable.signal-desktop
      unstable.tailscale
      unstable.zoom-us
      unstable.zulip
      usbutils
      virt-manager
      vlc
      virtiofsd
      whois
      wine
      wireshark-qt
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
      device = "192.168.1.32:/mnt/wd4t/data/home/backup/";
      fsType = "nfs";
    };
  };

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "electron-27.3.11" ];
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

  systemd.services = {
    NetworkManager-wait-online.enable = false;
  };

  system = {
    autoUpgrade.enable = true;
    stateVersion = "24.11";
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
  };

  users.users.dave = {
    isNormalUser = true;
    extraGroups = [
      "docker"
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

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  programs = {
    corectrl.enable = true;
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
    enable = true;
    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
    desktopManager.gnome.enable = true;
    videoDrivers = [ "amdgpu" ];
  };

  services.ollama = {
    package = unstable.ollama;
    enable = true;
    acceleration = "rocm";
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "11.0.2";
    };
    loadModels = [
      "deepseek-r1:8b"
      "dolphin3:8b"
    ];
  };

  services.open-webui = {
    enable = true;
    package = unstable.open-webui;
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
    docker.enable = true;
    libvirtd.enable = true;
    podman.enable = true;
  };
}
