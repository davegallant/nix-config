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
    unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.permittedInsecurePackages = [
        "electron-25.9.0" # caused by obsidian
      ];
    };
    defaultModules = [
      home-manager.nixosModules.home-manager
      ./modules/fonts.nix
      ./modules/packages.nix
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
            gc = {
              automatic = true;
              dates = "daily";
              options = "--delete-older-than 14d";
            };
          };

          nixpkgs.overlays = [
            (import ./modules/overlays)
          ];

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
      })
    ];
    desktopLinuxModules = [
      ./modules/services/netdata/default.nix
    ];
  in {
    hephaestus = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit unstable;};
      modules =
        [
          ./modules/machines/hephaestus/configuration.nix
          ./modules/machines/hephaestus/hardware.nix
        ]
        ++ defaultModules
        ++ desktopLinuxModules;
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
        ./modules/darwin.nix
        ./modules/machines/zelus/configuration.nix
        ./modules/packages.nix
        ./modules/upgrade-diff.nix

        ({config, ...}: {
          config = {
            nixpkgs.overlays = [
              (import ./modules/overlays)
            ];
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
        })
      ];
    };
  };
}
