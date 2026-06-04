{
  description = "nixos and macos configurations";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nirinit = {
      url = "github:amaanq/nirinit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vpngate = {
      url = "github:davegallant/vpngate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    weathr = {
      url = "github:Veirt/weathr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      darwin,
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      vpngate,
      weathr,
      ...
    }@inputs:
    let
      nixpkgsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [ "electron-39.8.10" ];
      };

      mkUnstable =
        system:
        import nixpkgs-unstable {
          inherit system;
          config = nixpkgsConfig;
        };

      mkSharedModules =
        {
          username,
          system,
          unstable,
          hmModule,
          hostname ? "",
          extraModules ? [ ],
        }:
        [
          ./packages.nix
          hmModule
          (_: {
            config = {
              nixpkgs.config = nixpkgsConfig;
              nixpkgs.overlays = [
                (import ./overlays)
                inputs.niri.overlays.niri
              ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username}.imports = [
                  ./home
                  inputs.nixvim.homeModules.nixvim
                  weathr.homeModules.weathr
                ]
                # On Linux the niri NixOS module declares the home-manager niri
                # options; on Darwin there is no NixOS module, so import the home
                # module directly so home/niri.nix (Linux-gated) still evaluates.
                ++ (if nixpkgs.lib.hasSuffix "-darwin" system then [ inputs.niri.homeModules.niri ] else [ ]);
                extraSpecialArgs = {
                  inherit unstable hostname;
                };
              };
            };
          })
        ]
        ++ extraModules;
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "aarch64-darwin"
          ]
          (
            system:
            f {
              inherit system;
              pkgs = import nixpkgs {
                inherit system;
                config = nixpkgsConfig;
              };
            }
          );

      nixosModuleSet = {
        ollama = import ./modules/ollama.nix;
      };
    in
    {
      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt);

      devShells = forEachSystem (
        { pkgs, ... }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              deadnix
              just
              nixfmt
              shellcheck
              shfmt
              statix
            ];
          };
        }
      );

      nixosModules = nixosModuleSet;

      nixosConfigurations =
        let
          mkNixos =
            {
              system,
              hostname,
              username ? "dave",
              extraModules ? [ ],
            }:
            let
              unstable = mkUnstable system;
            in
            nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit
                  unstable
                  vpngate
                  inputs
                  ;
              };
              modules = mkSharedModules {
                inherit
                  username
                  system
                  unstable
                  hostname
                  ;
                hmModule = home-manager.nixosModules.home-manager;
                extraModules = [
                  inputs.niri.nixosModules.niri
                  ./nixos.nix
                  ./hosts/${hostname}.nix
                  inputs.nirinit.nixosModules.nirinit
                ]
                ++ (builtins.attrValues nixosModuleSet)
                ++ extraModules;
              };
            };
        in
        {
          hephaestus = mkNixos {
            system = "x86_64-linux";
            hostname = "hephaestus";
          };
        };

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          unstable = mkUnstable system;
        in
        {
          kratos = darwin.lib.darwinSystem {
            inherit system;
            specialArgs = {
              inherit unstable inputs;
            };
            modules = mkSharedModules {
              username = "dave.gallant";
              hostname = "kratos";
              inherit system unstable;
              hmModule = home-manager.darwinModules.home-manager;
              extraModules = [
                ./hosts/kratos.nix
              ];
            };
          };
          helios = darwin.lib.darwinSystem {
            inherit system;
            specialArgs = {
              inherit unstable inputs;
            };
            modules = mkSharedModules {
              username = "dave.gallant";
              hostname = "helios";
              inherit system unstable;
              hmModule = home-manager.darwinModules.home-manager;
              extraModules = [
                ./hosts/helios.nix
              ];
            };
          };
        };
    };
}
