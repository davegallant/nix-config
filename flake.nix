{
  description = "nixos and macos configurations";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-needsreboot.url = "github:thefossguy/nixos-needsreboot/master";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:nix-community/stylix/release-25.05";
    vpngate.url = "github:davegallant/vpngate";
  };

  outputs =
    {
      self,
      darwin,
      determinate,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-master,
      stylix,
      vpngate,
      nixos-needsreboot,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      nixosConfigurations =
        let
          unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          master = import nixpkgs-master {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in
        {
          hephaestus = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit unstable;
              inherit master;
              inherit vpngate;
              inherit inputs;
            };
            modules = [
              ./hosts/hephaestus.nix
              ./common-packages.nix
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
                        ];
                        trusted-public-keys = [
                          "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08="
                        ];
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
                        ./home.nix
                        inputs.nixvim.homeManagerModules.nixvim
                      ];
                      extraSpecialArgs = {
                        inherit unstable;
                        inherit master;
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
          master = import nixpkgs-master {
            config.allowUnfree = true;
            inherit system;
          };
        in
        {
          zelus = darwin.lib.darwinSystem {
            inherit system;
            specialArgs = {
              inherit unstable;
              inherit master;
            };

            modules = [
              home-manager.darwinModules.home-manager
              stylix.darwinModules.stylix
              ./hosts/zelus.nix
              ./common-packages.nix
              (
                { ... }:
                {
                  config = {
                    nixpkgs.overlays = [ (import ./overlays) ];
                    home-manager = {
                      useGlobalPkgs = true;
                      useUserPackages = true;
                      users."dave.gallant".imports = [
                        ./home.nix
                        inputs.nixvim.homeManagerModules.nixvim
                      ];
                      extraSpecialArgs = {
                        inherit unstable;
                        inherit master;
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
