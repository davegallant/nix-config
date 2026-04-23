{
  pkgs,
  lib,
  unstable,
  ...
}:
{
  environment.systemPackages =
    with pkgs;
    [
      # desktop apps
      bitwarden-desktop
      feishin
      gimp-with-plugins
      httpie-desktop
      mission-center
      pika-backup
      pinta
      qbittorrent
      unstable.brave
      unstable.obsidian
      unstable.signal-desktop

      # media
      calibre
      libation
      vlc

      # security
      bleachbit
      clamtk
      opensnitch-ui

      # system utilities
      unstable.ghostty
      virt-manager
      wayland-utils
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
      # desktop apps
      discord
      freefilesync
      unstable.beekeeper-studio
      unstable.zoom-us
      unstable.code-cursor

      # media
      unstable.spotify

      # keyboard
      via

      # gaming
      heroic
      ludusavi
      mupen64plus
      protonup-qt
      unstable.ryubing
      unstable.lutris
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
}
