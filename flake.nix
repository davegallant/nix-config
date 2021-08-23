{
  description = "nixos and macos configurations";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";


  };

  outputs = { self, darwin, home-manager, nixpkgs, nixos-hardware, ... }@inputs: {

    nixosConfigurations =
      let
        defaultModules = [
          home-manager.nixosModules.home-manager
          ./common/desktop.nix
          ./common/fonts.nix
          ./common/linux.nix
          ./common/netdata/default.nix
          ./common/opensnitch/default.nix
          ./common/networking.nix
          ./common/packages.nix
          ./common/printing.nix

          ({ config, lib, lib', ... }: {
            config = {
              _module.args = {
                lib' = lib // import ./lib { inherit config lib; };
              };

              nix = {
                autoOptimiseStore = true;
                binaryCaches = [ "https://davegallant.cachix.org" ];
                binaryCachePublicKeys = [
                  "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08="
                ];
                useSandbox = false;
                registry = { nixpkgs.flake = nixpkgs; };
                trustedUsers = [ "root" "dave" ];
              };

              nixpkgs.overlays = [ (import ./modules/overlays) inputs.neovim-nightly-overlay.overlay ];

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.dave.imports = [ ./home/default.nix ];
              };
            };
          })
        ];
      in
      {
        hephaestus = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/hephaestus/configuration.nix
            ./machines/hephaestus/hardware.nix
          ] ++ defaultModules;
        };
      };
    darwinConfigurations = {
      demeter = darwin.lib.darwinSystem {

        modules = [
          home-manager.darwinModules.home-manager
          ./common/darwin.nix
          ./common/packages.nix
          ./machines/demeter/configuration.nix
          ./modules/darwin/default.nix

          ({ config, ... }: {
            config = {
              nixpkgs.overlays = [
                inputs.neovim-nightly-overlay.overlay
                (import ./modules/overlays)
              ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.dave.imports = [ ./home/default.nix ];
              };
            };
          })
        ];
      };
    };
  };
}

