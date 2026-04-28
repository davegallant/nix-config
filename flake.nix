{
  description = "nixos and macos configurations";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake/e43ef13f23c2c7ae5b10e842745cb345faff4f40"; # 26.04
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nirinit = {
      url = "github:amaanq/nirinit";
      inputs.nixpkgs.follows = "nixpkgs"; # optional, keeps dependencies synced
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
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
      mkUnstable =
        system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
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
          (
            { ... }:
            {
              config = {
                nixpkgs.config.allowUnfree = true;
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
                  ++ (if nixpkgs.lib.hasSuffix "-darwin" system then [ inputs.niri.homeModules.niri ] else [ ]);
                  extraSpecialArgs = {
                    inherit unstable hostname;
                  };
                };
              };
            }
          )
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
                config.allowUnfree = true;
              };
            }
          );

      nixosModuleSet = {
        features = import ./modules/features.nix;
        ollama = import ./modules/ollama.nix;
      };
    in
    {
      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);

      devShells = forEachSystem (
        { pkgs, ... }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              just
              nixfmt-rfc-style
              shellcheck
              shfmt
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

          kratos = mkNixos {
            system = "aarch64-linux";
            hostname = "kratos";
          };
        };

      darwinConfigurations =
        let
          system = "aarch64-darwin";
          unstable = mkUnstable system;
        in
        {
          zelus = darwin.lib.darwinSystem {
            inherit system;
            specialArgs = {
              inherit unstable inputs;
            };
            modules = mkSharedModules {
              username = "dave.gallant";
              hostname = "zelus";
              inherit system unstable;
              hmModule = home-manager.darwinModules.home-manager;
              extraModules = [
                ./hosts/zelus.nix
              ];
            };
          };
        };
    };
}
