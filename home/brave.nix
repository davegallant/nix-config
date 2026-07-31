{
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  config = lib.mkIf stdenv.isLinux {
    programs.brave = {
      enable = true;
      # unstable.brave has no working `.override` right now (nixpkgs brave-origin
      # refactor lost it), so append flags via overrideAttrs on preFixup instead.
      package = unstable.brave.overrideAttrs (old: {
        preFixup = ''
          ${old.preFixup or ""}
          gappsWrapperArgs+=(
            --add-flags "--disable-features=MediaRouter --no-pings"
          )
        '';
      });
    };
  };
}
