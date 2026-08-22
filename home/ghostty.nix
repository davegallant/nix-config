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
    ${lib.optionalString pkgs.stdenv.isLinux "async-backend = epoll"}
  '';
}
