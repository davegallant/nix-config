{
  lib,
  pkgs,
  unstable,
  ...
}:
{
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo -e "\e[36mPackage version diffs:\e[0m"
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      fi
    '';
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      auto-optimise-store = lib.mkDefault true;
      builders-use-substitutes = true;
      max-jobs = "auto";
      cores = 0;
      substituters = [
        "https://davegallant.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 14d";
    };
  };

  documentation.man.cache.enable = false;

  zramSwap.enable = true;

  boot.tmp.useTmpfs = true;

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/Toronto";

  programs.fish.enable = true;
  programs.nix-ld.enable = lib.mkDefault true;

  services.tailscale = {
    enable = true;
    package = unstable.tailscale;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  users.users.dave = {
    isNormalUser = true;
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    bleachbit
    borgbackup
    bruno
    calibre
    clamtk
    evince
    heroic
    libation
    libnotify
    ludusavi
    lutris
    mission-center
    mupdf
    opensnitch-ui
    pinta
    protonup-qt
    qbittorrent
    ryubing
    unstable.ghostty
    unstable.spotify
    via
    virt-manager
    vlc
    wayland-utils
    wine
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    fira-mono
    font-awesome
    liberation_ttf
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "Noto Sans Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  services.desktopManager.plasma6.enable = true;

  services.displayManager = {
    defaultSession = "plasma";
    autoLogin = {
      enable = true;
      user = "dave";
    };
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.flatpak.enable = true;

  services.tumbler.enable = true;

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

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = false; # avoids broken setuid bwrap wrapper
    extest.enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
