{
  self,
  darwin,
  home-manager,
  nixpkgs,
  nixpkgs-unstable,
  nixos-hardware,
  nix-ld,
  ...
} @ inputs: {
  nixosConfigurations = let
    modulesDir = ./modules;
    unstable = import nixpkgs-unstable {};
    defaultModules = [
      home-manager.nixosModules.home-manager
      ./modules/common/fonts.nix
      ./modules/packages/common.nix
      ./modules/upgrade-diff.nix

      ({
        config,
        lib,
        lib',
        ...
      }: {
        config = {
          _module.args = {
            lib' = lib // import ./lib {inherit config lib;};
          };

          nix = {
            settings = {
              auto-optimise-store = true;
              sandbox = false;
              substituters = ["https://davegallant.cachix.org"];
              trusted-users = ["root" "dave"];
              trusted-public-keys = [
                "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08="
              ];
            };
            registry = {nixpkgs.flake = nixpkgs;};
          };

          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };

          nixpkgs.overlays = [
            (import ./modules/overlays)
          ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.dave.imports = [./home/default.nix];
            extraSpecialArgs = {
              inherit unstable;
            };
          };
        };
      })
    ];
    desktopLinuxModules = [
      ./modules/common/linux-desktop.nix
      ./modules/common/linux.nix
      ./modules/common/networking.nix
      ./modules/common/printing.nix
      ./modules/packages/linux-desktop.nix
      ./modules/packages/linux.nix
      ./modules/services/netdata/default.nix
    ];
  in {
    hephaestus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit unstable;};
      modules =
        [
          ./modules/machines/hephaestus/configuration.nix
          ./modules/machines/hephaestus/hardware.nix
        ]
        ++ defaultModules
        ++ desktopLinuxModules;
    };
    aether = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ./modules/machines/aether/configuration.nix
          nix-ld.nixosModules.nix-ld
        ]
        ++ defaultModules;
    };
  };

  darwinConfigurations = let
    system = "aarch64-darwin";
    unstable = import nixpkgs-unstable {
      inherit system;
    };
  in {
    zelus = darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {inherit unstable;};

      modules = [
        home-manager.darwinModules.home-manager
        ./modules/common/darwin.nix
        ./modules/packages/common.nix
        ./modules/machines/zelus/configuration.nix
        ./modules/darwin/default.nix
        ./modules/upgrade-diff.nix

        ({config, ...}: {
          config = {
            nixpkgs.overlays = [
              (import ./modules/overlays)
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users."dave.gallant".imports = [./home/default.nix];
              extraSpecialArgs = {
                inherit unstable;
              };
            };
          };
        })
      ];
    };
  };
}
