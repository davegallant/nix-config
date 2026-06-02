{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."ghostty/config".text = ''
    command = /etc/profiles/per-user/dave.gallant/bin/fish
    font-size = ${if pkgs.stdenv.isDarwin then "16" else "14"}
    clipboard-trim-trailing-spaces = true
  '';
}
