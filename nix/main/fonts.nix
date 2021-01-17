
{ pkgs, ... }:

{
  # Set system-wide fonts.
  fonts.fonts = with pkgs; [
    dejavu_fonts
    fira-code
    fira-code-symbols
    fira-mono
    font-awesome
    google-fonts
    liberation_ttf # Free replacement for MS Fonts.
    noto-fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-emoji
    noto-fonts-extra
  ];

  # Set default fonts.
  fonts.fontconfig.defaultFonts = {
    sansSerif = [
      "Noto Sans"
    ];
    serif = [
      "Noto Serif"
    ];
    monospace = [
      "MesloLGS Nerd Font"
      "Noto Sans Mono"
    ];
    emoji = [
      "Noto Color Emoji"
    ];
  };
}
