{
  description = "nixos and macos configurations";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nixpkgs-master.url = "github:NixOs/nixpkgs/master";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0.2411.3913";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/release-24.11";
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
      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
          };
        };
      });
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
        };
      });
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
            };
            modules = [
              ./hosts/hephaestus.nix
              ./common-packages.nix
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
