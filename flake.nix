{
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "/nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, home-manager, nixpkgs, nixos-hardware }: {
    nixosConfigurations = let
      defaultModules = [
        home-manager.nixosModules.home-manager
        ./main/fonts.nix
        ./main/general.nix
        ./main/kernel.nix
        ./main/packages.nix
        ./main/printing.nix

        ({ config, lib, lib', ... }: {
          config = {
            _module.args = {
              lib' = lib // import ./lib { inherit config lib; };
            };

            nix.registry = { nixpkgs.flake = nixpkgs; };

            nixpkgs.overlays = [ (import ./overlays) ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.dave.imports = [ ./home/default.nix ];
            };
          };
        })
      ];
    in {
      hephaestus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/hephaestus/configuration.nix
          ./machines/hephaestus/hardware.nix
          ./modules/g810-led.nix
        ] ++ defaultModules;
      };
      hermes = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-t480s
          ./machines/hermes/configuration.nix
          ./machines/hermes/hardware.nix
        ] ++ defaultModules;
      };
    };
  };
}

