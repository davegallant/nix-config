{
  config,
  pkgs,
  unstable,
  ...
}: {
  imports = [./hardware.nix];

  hardware.opengl.enable = true;

  nixpkgs.config.allowUnfree = true;

  networking = {
    iproute2.enable = true;
    hostName = "hephaestus";
    interfaces.enp34s0 = {
      useDHCP = true;
    };
    firewall = {
      allowedUDPPorts = [
        41641 # tailscale
      ];
    };
    firewall = {
      allowPing = false;
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = ["tailscale0"];
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = ["ntfs"];

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
    extraGroups = ["docker" "wheel" "libvirtd" "corectrl"];
    shell = pkgs.zsh;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  time.timeZone = "America/Toronto";

  hardware.pulseaudio.enable = true;

  # Vulkan
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # Steam
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [libva];
  hardware.pulseaudio.support32Bit = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    podman.enable = true;
  };

  programs = {
    corectrl.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
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
    xserver.videoDrivers = ["amdgpu"];
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
    };
  };

  environment.systemPackages = with pkgs; [
    android-tools
    bitwarden
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
    gnomeExtensions.appindicator
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.grand-theft-focus
    gnomeExtensions.notification-banner-reloaded
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.tailscale-status
    gnomeExtensions.tray-icons-reloaded
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
    podman-compose
    psst
    qemu
    rustup
    ryujinx
    signal-desktop
    strace
    tailscale
    traceroute
    ungoogled-chromium
    unstable.logseq
    unstable.obsidian
    unstable.yuzu
    unstable.zoom-us
    usbutils
    virt-manager
    vlc
    whois
    wine
    wine64
    wireshark-qt
  ];
}
