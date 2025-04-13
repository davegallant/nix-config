{
  description = "nixos and macos configurations";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/*";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/release-24.11";
    vpngate.url = "github:davegallant/vpngate";
  };

  outputs =
    {
      darwin,
      fh,
      determinate,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      stylix,
      vpngate,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in
        {
          hephaestus = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit fh;
              inherit unstable;
              inherit vpngate;
            };
            modules = [
              ./fonts.nix
              ./hosts/hephaestus/configuration.nix
              ./packages.nix
              ./services/netdata/default.nix
              ./upgrade-diff.nix
              determinate.nixosModules.default
              home-manager.nixosModules.home-manager
              stylix.nixosModules.stylix
              (
                { ... }:
                {
                  config = {
                    nix = {
                      settings = {
                        auto-optimise-store = true;
                        sandbox = false;
                        substituters = [ "https://davegallant.cachix.org" ];
                        trusted-users = [
                          "root"
                          "dave"
                        ];
                        trusted-public-keys = [ "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08=" ];
                      };
                      registry = {
                        nixpkgs.flake = nixpkgs;
                      };
                      gc = {
                        automatic = true;
                        dates = "daily";
                        options = "--delete-older-than 14d";
                      };
                    };

                    nixpkgs.overlays = [ (import ./overlays) ];

                    home-manager = {
                      useGlobalPkgs = true;
                      useUserPackages = true;
                      users.dave.imports = [
                        ./home/default.nix
                        inputs.nixvim.homeManagerModules.nixvim
                      ];
                      extraSpecialArgs = {
                        inherit unstable;
                      };
                    };
                  };
                }
              )
            ];
          };
        };

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          unstable = import nixpkgs-unstable {
            config.allowUnfree = true;
            inherit system;
          };
        in
        {
          zelus = darwin.lib.darwinSystem {
            inherit system;
            specialArgs = {
              inherit unstable;
            };

            modules = [
              home-manager.darwinModules.home-manager
              stylix.darwinModules.stylix
              ./hosts/zelus/configuration.nix
              ./packages.nix
              ./upgrade-diff.nix

              (
                { ... }:
                {
                  config = {
                    nixpkgs.overlays = [ (import ./overlays) ];
                    home-manager = {
                      useGlobalPkgs = true;
                      useUserPackages = true;
                      users."dave.gallant".imports = [
                        ./home/default.nix
                        inputs.nixvim.homeManagerModules.nixvim
                      ];
                      extraSpecialArgs = {
                        inherit unstable;
                      };
                    };
                  };
                }
              )
            ];
          };
        };
    };
}
