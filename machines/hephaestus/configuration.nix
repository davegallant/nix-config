{ config
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
    dash-to-dock
    grand-theft-focus
    notification-banner-reloaded
    quick-settings-tweaker
    tailscale-status
    tray-icons-reloaded
  ];
in
{
  imports = [ ./hardware.nix ];

  hardware.opengl.enable = true;

  nixpkgs.config.allowUnfree = true;

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

  systemd.services.NetworkManager-wait-online.enable = false;

  boot.kernelPackages = pkgs.linuxPackages;
  boot.supportedFilesystems = [ "ntfs" ];

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
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
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
    xserver.videoDrivers = [ "amdgpu" ];
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

  environment.systemPackages = with pkgs;
    [
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
      psst
      qemu
      rustup
      strace
      tailscale
      traceroute
      ungoogled-chromium
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
}
