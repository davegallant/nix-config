{ config, lib, ... }:

with lib; rec {

  pkgsImport = pkgs:
    import pkgs {
      config = config.nixpkgs.config;
      overlays = config.nixpkgs.overlays;
      system = config.nixpkgs.system;
    };

}
