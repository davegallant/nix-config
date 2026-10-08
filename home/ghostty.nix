{
  lib,
  pkgs,
  ...
}:
{
  xdg.configFile."ghostty/config".text = ''
    command = /run/current-system/sw/bin/fish
    font-size = ${if pkgs.stdenv.isDarwin then "16" else "12"}
    clipboard-trim-trailing-spaces = true
    theme = light:Tomorrow,dark:Ghostty Default
    ${lib.optionalString pkgs.stdenv.isLinux "async-backend = epoll"}
  '';

  # Ghostty's built-in colours have no theme name, so the dark side of
  # `theme = light:...,dark:...` needs them as a theme file.
  xdg.configFile."ghostty/themes/Ghostty Default".text = ''
    background = #282c34
    foreground = #ffffff
    palette = 0=#1d1f21
    palette = 1=#cc6666
    palette = 2=#b5bd68
    palette = 3=#f0c674
    palette = 4=#81a2be
    palette = 5=#b294bb
    palette = 6=#8abeb7
    palette = 7=#c5c8c6
    palette = 8=#666666
    palette = 9=#d54e53
    palette = 10=#b9ca4a
    palette = 11=#e7c547
    palette = 12=#7aa6da
    palette = 13=#c397d8
    palette = 14=#70c0b1
    palette = 15=#eaeaea
  '';
}
