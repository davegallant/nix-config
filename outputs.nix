{
  self,
  darwin,
  home-manager,
  nixpkgs,
  nixos-hardware,
  nix-ld,
  ...
} @ inputs: {
  nixosConfigurations = let
    defaultModules = [
      home-manager.nixosModules.home-manager
      ./common/fonts.nix
      ./packages/common.nix

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
          };
        };
      })
    ];
    desktopLinuxModules = [
      ./common/linux-desktop.nix
      ./common/linux.nix
      ./common/networking.nix
      ./common/printing.nix
      ./packages/linux-desktop.nix
      ./packages/linux.nix
      ./services/netdata/default.nix
    ];
  in {
    hephaestus = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ./machines/hephaestus/configuration.nix
          ./machines/hephaestus/hardware.nix
        ]
        ++ defaultModules
        ++ desktopLinuxModules;
    };
    aether = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          ./machines/aether/configuration.nix
          nix-ld.nixosModules.nix-ld
        ]
        ++ defaultModules;
    };

    darwinConfigurations = {
      zelus = darwin.lib.darwinSystem {
        system = "aarch64-darwin";

        modules = [
          home-manager.darwinModules.home-manager
          ./common/darwin.nix
          ./packages/common.nix

          ./machines/zelus/configuration.nix

          ./modules/darwin/default.nix

          ({config, ...}: {
            config = {
              nixpkgs.overlays = [
                (import ./modules/overlays)
              ];
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users."dave.gallant".imports = [./home/default.nix];
              };
            };
          })
        ];
      };
    };
  };
}
