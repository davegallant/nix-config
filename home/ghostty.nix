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
    ${lib.optionalString pkgs.stdenv.isDarwin "# explicit bind works around cmd+v not pasting into the search bar (ghostty#10749)\nkeybind = super+v=paste_from_clipboard"}
  '';
}
