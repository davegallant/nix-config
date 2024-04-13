{ config
, lib
, modulesPath
, pkgs
, unstable
, ...
}:
let
  gnomeExtensions = with pkgs.gnomeExtensions; [
    appindicator
    bluetooth-quick-connect
    blur-my-shell
    caffeine
    clipboard-indicator
    grand-theft-focus
    notification-banner-reloaded
    quick-settings-tweaker
    tailscale-status
    tray-icons-reloaded
  ];
in
{

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      xpadneo
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

    supportedFilesystems = [ "ntfs" ];

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

  environment.systemPackages = with pkgs;
    [
      android-tools
      bitwarden
      chromium
      cryptsetup
      deja-dup
      discord
      docker
      docker-compose
      foliate
      ghostscript
      gimp-with-plugins
      glibcLocales
      gnome.gnome-tweaks
      iputils
      kazam
      legendary-gl
      lm_sensors
      mullvad-vpn
      netdata
      nfs-utils
      pavucontrol
      pinentry-curses
      podman
      qemu
      sbx-h6-rgb
      strace
      tailscale
      traceroute
      unstable.burpsuite
      unstable.logseq
      unstable.obsidian
      unstable.ryujinx
      unstable.signal-desktop
      usbutils
      virt-manager
      vlc
      whois
      wine
      wine64
      wireshark-qt
      zoom-us
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
    "/mnt/synology-2b/backups" = {
      device = "192.168.1.178:/volume1/Backups";
      fsType = "nfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/5d6d0388-2b15-4ff1-9f0f-391818a76090"; }
  ];

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };
  };

  networking = {
    iproute2.enable = true;
    hostName = "hephaestus";
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
    stateVersion = "23.11";
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    package = pkgs.nixUnstable;
  };

  users.users.dave = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" "libvirtd" "corectrl" ];
    shell = pkgs.zsh;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/Toronto";

  hardware = {
    opengl.enable = true;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    pulseaudio.enable = true;
    # Vulkan
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
    # Steam
    opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    pulseaudio.support32Bit = true;
  };

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
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };
    gnome.gnome-keyring.enable = true;
    mullvad-vpn.enable = false;
    printing.enable = true;
    resolved.enable = true;
    sshd.enable = true;
    tailscale.enable = true;
    udev.extraRules = ''
      ACTION=="add", ATTR{idVendor}=="041e", ATTR{idProduct}=="3255", RUN+="${pkgs.sbx-h6-rgb}/bin/sbx-h6-ctl -c c010ff 041e:3255"
    '';
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = false;
        };
      };
      desktopManager = {
        gnome = {
          enable = true;
        };
      };
      videoDrivers = [ "amdgpu" ];
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    podman.enable = true;
  };
}
