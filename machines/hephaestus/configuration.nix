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
    kernelPackages = pkgs.linuxPackages_latest;

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
      android-tools
      blender
      cryptsetup
      discord
      docker
      docker-compose
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
      mitmproxy
      netdata
      nfs-utils
      pavucontrol
      pika-backup
      pinentry-curses
      podman
      qemu
      ryujinx
      sbx-h6-rgb
      strace
      unityhub
      unstable.burpsuite
      unstable.dotnet-sdk_8
      unstable.ghostty
      unstable.signal-desktop
      unstable.spotify
      unstable.tailscale
      unstable.zoom-us
      unstable.zulip
      usbutils
      virt-manager
      vlc
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

  swapDevices = [ { device = "/dev/disk/by-uuid/5d6d0388-2b15-4ff1-9f0f-391818a76090"; } ];

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
    interfaces.enp34s0 = {
      useDHCP = true;
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

  services = {
    avahi = {
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
    flatpak.enable = true;
    gnome.gnome-keyring.enable = true;
    mullvad-vpn.enable = false;
    printing.enable = true;
    resolved.enable = true;
    sshd.enable = true;
    tailscale = {
      enable = true;
      package = unstable.tailscale;
    };
    udev.extraRules = ''
      ACTION=="add", ATTR{idVendor}=="041e", ATTR{idProduct}=="3255", RUN+="${pkgs.sbx-h6-rgb}/bin/sbx-h6-ctl -c c010ff 041e:3255"
    '';
    xserver = {
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
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    podman.enable = true;
  };
}
