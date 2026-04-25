{ pkgs, ... }:
{
  xdg.configFile."ghostty/config".text = ''
    command = ${if pkgs.stdenv.isDarwin then "/opt/homebrew/bin/et kratos" else "fish"}
    font-size = ${if pkgs.stdenv.isDarwin then "16" else "14"}
    clipboard-trim-trailing-spaces = true
    background-opacity = 0.85
    background-opacity-cells = true
    unfocused-split-opacity = 0.7
  '';
}
