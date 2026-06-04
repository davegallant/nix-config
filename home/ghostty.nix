{
  pkgs,
  ...
}:
{
  xdg.configFile."ghostty/config".text = ''
    command = /run/current-system/sw/bin/fish
    font-size = ${if pkgs.stdenv.isDarwin then "16" else "14"}
    clipboard-trim-trailing-spaces = true
  '';
}
