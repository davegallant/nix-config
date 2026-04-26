{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  config = lib.mkIf (config.features.desktop.enable && stdenv.isLinux) {
    programs.brave = {
      enable = true;
      package = unstable.brave.override {
        commandLineArgs = [
          "--disable-features=MediaRouter"
          "--no-pings"
        ];
      };
    };
  };
}
