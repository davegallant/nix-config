{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
{
  config = lib.mkIf config.features.desktop.enable {
    environment.systemPackages =
      with pkgs;
      [
        bitwarden-desktop
        bleachbit
        calibre
        clamtk
        feishin
        gimp-with-plugins
        httpie-desktop
        libation
        mission-center
        opensnitch-ui
        pika-backup
        pinta
        qbittorrent
        unstable.ghostty
        unstable.signal-desktop
        virt-manager
        vlc
        wayland-utils
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
        discord
        freefilesync
        heroic
        lutris
        ludusavi
        mupen64plus
        protonup-qt
        ryubing
        unstable.beekeeper-studio
        unstable.spotify
        unstable.zoom-us
        via
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

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
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

    services.nirinit = {
      enable = true;
      settings = {
        launch = {
          "brave-browser" = "brave";
          "com.mitchellh.ghostty" = "ghostty";
          "signal" = "signal-desktop";
        };
        skip.apps = [
          "brave-ophjlpahpchlmihnnnihgmmeilfjmjjc-Default"
          "opensnitch_ui"
          "steam"
        ];
      };
    };

    services.tumbler.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config.niri.default = [
        "gtk"
      ];
      config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
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

    services.printing = {
      enable = true;
      browsing = false;
    };
    systemd.services.cups-browsed.enable = false;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
