{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    dejavu_fonts
    fira-code
    fira-code-symbols
    fira-mono
    font-awesome
    google-fonts
    liberation_ttf
    nerdfonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    noto-fonts-extra
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" ];
    serif = [ "Noto Serif" ];
    monospace = [ "Noto Sans Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
