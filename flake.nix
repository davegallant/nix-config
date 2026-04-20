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
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vpngate.url = "github:davegallant/vpngate";
    paneru = {
      url = "github:karinushka/paneru";
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
                  ++ (if system != "x86_64-linux" then [ inputs.niri.homeModules.niri ] else [ ]);
                  extraSpecialArgs = {
                    inherit unstable;
                  };
                };
              };
            }
          )
        ]
        ++ extraModules;
    in
    {
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
                inherit username system unstable;
                hmModule = home-manager.nixosModules.home-manager;
                extraModules = [ ./hosts/${hostname}.nix ] ++ extraModules;
              };
            };
        in
        {
          hephaestus = mkNixos {
            system = "x86_64-linux";
            hostname = "hephaestus";
            extraModules = [
              (
                { ... }:
                {
                  config.nix = {
                    settings = {
                      auto-optimise-store = true;
                      substituters = [ "https://davegallant.cachix.org" ];
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
                }
              )
            ];
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
              inherit system unstable;
              hmModule = home-manager.darwinModules.home-manager;
              extraModules = [
                ./hosts/zelus.nix
                inputs.paneru.darwinModules.paneru
              ];
            };
          };
        };
    };
}
