{ pkgs, ... }:
let
  opencode-usage = pkgs.callPackage ./opencode-usage/package.nix { };
in
{
  home.file."Applications/OpenCode Usage.app".source =
    "${opencode-usage}/Applications/OpenCode Usage.app";
}
