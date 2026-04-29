{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."ghostty/config".text = ''
    command = ${
      if pkgs.stdenv.isDarwin then "/opt/homebrew/bin/et ${config.features.remoteHost}" else "fish"
    }
    font-size = ${if pkgs.stdenv.isDarwin then "16" else "14"}
    clipboard-trim-trailing-spaces = true
  '';
}
