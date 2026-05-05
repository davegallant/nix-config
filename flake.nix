{
  description = "nixos and macos configurations";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/549bd84d6279f9852cae6225e372cc67fb91a4c1"; # renovate: currentValue=nixos-unstable
    nixpkgs.url = "github:NixOS/nixpkgs/0c88e1f2bdb93d5999019e99cb0e61e1fe2af4c5"; # renovate: currentValue=nixos-25.11
    darwin = {
      url = "github:lnl7/nix-darwin/ebec37af18215214173c98cf6356d0aca24a2585"; # renovate: currentValue=nix-darwin-25.11
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/0585fbf645640973e3398863bbaf3bd1ddce4a51"; # renovate: currentValue=release-25.11
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake/945748d71d3422d4f1dada2cd10222e34ed9d767";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nirinit = {
      url = "github:amaanq/nirinit";
      inputs.nixpkgs.follows = "nixpkgs"; # optional, keeps dependencies synced
    };
    nixvim = {
      url = "github:nix-community/nixvim/b8f76bf5751835647538ef8784e4e6ee8deb8f95"; # renovate: currentValue=nixos-25.11
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
