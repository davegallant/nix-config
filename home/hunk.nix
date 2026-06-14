{
  pkgs,
  ...
}:
let
  hunk = pkgs.callPackage ./hunk/package.nix { };
in
{
  home.packages = [ hunk ];
}
