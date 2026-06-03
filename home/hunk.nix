{
  pkgs,
  ...
}:
let
  hunk = pkgs.callPackage ./hunk/package.nix { };
in
{
  config = {
    home.packages = [ hunk ];
  };
}
