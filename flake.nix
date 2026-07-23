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
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pvectl = {
      url = "github:davegallant/pvectl";
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
      pvectl,
      vpngate,
      weathr,
      ...
    }@inputs:
    let
      nixpkgsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [ "pnpm-10.29.2" ];
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
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username}.imports = [
                  ./home
                  inputs.nixvim.homeModules.nixvim
                  weathr.homeModules.weathr
                ];
                extraSpecialArgs = {
                  inherit unstable hostname pvectl vpngate;
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
                  pvectl
                  vpngate
                  inputs
                  ;
              };
              modules = mkSharedModules {
                inherit
                  username
                  unstable
                  hostname
                  ;
                hmModule = home-manager.nixosModules.home-manager;
                extraModules = [
                  ./nixos.nix
                  ./hosts/${hostname}.nix
                ]
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
          mkDarwin =
            { hostname, username }:
            darwin.lib.darwinSystem {
              inherit system;
              specialArgs = {
                inherit
                  inputs
                  pvectl
                  unstable
                  username
                  vpngate
                  ;
              };
              modules = mkSharedModules {
                inherit
                  hostname
                  unstable
                  username
                  ;
                hmModule = home-manager.darwinModules.home-manager;
                extraModules = [
                  ./darwin.nix
                  ./hosts/${hostname}.nix
                ];
              };
            };
        in
        {
          kratos = mkDarwin {
            hostname = "kratos";
            username = "dave.gallant";
          };
          helios = mkDarwin {
            hostname = "helios";
            username = "dave";
          };
        };
    };
}
