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
    "/mnt/tank/media" = {
      device = "192.168.1.16:/mnt/tank/media";
      fsType = "nfs";
      options = [
        "_netdev"
        "noauto"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
        "x-systemd.mount-timeout=10"
      ];
    };
    "/mnt/tank/backups" = {
      device = "192.168.1.16:/mnt/tank/backups";
      fsType = "nfs";
      options = [
        "_netdev"
        "noauto"
        "x-systemd.automount"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "x-systemd.idle-timeout=60"
        "x-systemd.mount-timeout=10"
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  # npm-installed tooling runs via nix-ld (nixos.nix)
  environment.systemPackages = with pkgs; [
    # LINE needs a manually-fetched installer added to the store first — see
    # pkgs/line.nix for instructions. Re-add once that's done on hephaestus:
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
    hostName = "hephaestus";
    hostId = "861d59c4";
    firewall = {
      allowPing = true;
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
    };
    networkmanager.enable = true;
  };

  # Auto-login so the Plasma session (and Sunshine, which is tied to
  # graphical-session.target) is always up after a reboot with no manual
  # console login.
  services.displayManager.autoLogin = {
    enable = true;
    user = "dave";
  };

  # KDE's compositor doesn't implement the wlroots screencopy protocol, so
  # Sunshine falls back to KMS/DRM capture on Plasma Wayland, which needs
  # CAP_SYS_ADMIN.
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    # Covers LAN (mDNS auto-discovery) and Tailscale. mDNS doesn't cross
    # the tailnet, so pair from off-LAN by adding the host in Moonlight
    # manually via its Tailscale IP/MagicDNS name.
    openFirewall = true;
    settings = {
      # Steam's steamwebhelper process grabs port 47990 (Sunshine's
      # default web UI port, offset +1 from the default base of 47989)
      # for its own local IPC, and reclaims it on every Steam relaunch.
      # Move Sunshine's whole port range off the default to avoid the
      # collision instead of relying on start order.
      port = 48989;
    };
    applications.apps = [
      {
        name = "Desktop";
        prep-cmd = [
          {
            do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.2560x1440@60";
            undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.3840x2160@60";
          }
        ];
      }
    ];
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
    "uinput" # lets Sunshine create virtual gamepads for Moonlight clients
    "wheel"
  ];

  # Let dave's systemd --user instance (tmux-server, etc.) keep running after
  # SSH sessions end and start again on boot, without needing an active login.
  users.manageLingering = true;
  users.users.dave.linger = true;

  hardware.enableRedistributableFirmware = true;
  hardware.keyboard.qmk.enable = true;
  # udev rules for Steam Controller / Xbox / PS / other gamepads
  hardware.steam-hardware.enable = true;

  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;

  # Hephaestus is a VM that should never sleep/suspend/hibernate
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

  services.ollama = {
    package = unstable.ollama-rocm;
    enable = true;
    host = "0.0.0.0";
    rocmOverrideGfx = "11.0.2";
    loadModels = [ "qwen3.5:9b" ];
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1";
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
