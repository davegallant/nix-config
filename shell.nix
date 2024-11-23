let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };

in
pkgs.mkShell {
  shellHook = ''
    ${(import ./default.nix).pre-commit-check.shellHook}
  '';
}
