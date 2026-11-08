{
  lib,
  pkgs,
  bravePkgs,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  config = lib.mkIf stdenv.isLinux {
    programs.brave = {
      enable = true;
      package = bravePkgs.brave.overrideAttrs (old: {
        preFixup = ''
          ${old.preFixup or ""}
          gappsWrapperArgs+=(
            --unset QT_PLUGIN_PATH
            --add-flags "--disable-features=MediaRouter --no-pings"
          )
        '';
      });
    };
  };
}
