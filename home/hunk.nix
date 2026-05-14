{
  config,
  lib,
  pkgs,
  ...
}:
let
  hunk = pkgs.callPackage ./hunk/package.nix { };
in
{
  config = lib.mkIf config.features.ai.enable {
    home.packages = [ hunk ];
  };
}
