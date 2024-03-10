{ self
, darwin
, home-manager
, nixpkgs
, nixpkgs-unstable
, nixos-hardware
, nix-ld
, ...
} @ inputs: {
  nixosConfigurations =
    let
      modulesDir = ./modules;
      unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ ];
      };
      defaultModules = [
        home-manager.nixosModules.home-manager
        ./fonts.nix
        ./packages.nix
        ./upgrade-diff.nix

        ({ config
         , lib
         , lib'
         , ...
         }: {
          config = {
            _module.args = {
              lib' = lib // import ./lib { inherit config lib; };
            };

            nix = {
              settings = {
                auto-optimise-store = true;
                sandbox = false;
                substituters = [ "https://davegallant.cachix.org" ];
                trusted-users = [ "root" "dave" ];
                trusted-public-keys = [
                  "davegallant.cachix.org-1:SsUMqL4+tF2R3/G6X903E9laLlY1rES2QKFfePegF08="
                ];
              };
              registry = { nixpkgs.flake = nixpkgs; };
              gc = {
                automatic = true;
                dates = "daily";
                options = "--delete-older-than 14d";
              };
            };

            nixpkgs.overlays = [
              (import ./overlays)
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
    in
    {
      hephaestus = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit unstable; };
        modules =
          [
            ./machines/hephaestus/configuration.nix
            ./machines/hephaestus/hardware.nix
            ./services/netdata/default.nix
          ]
          ++ defaultModules;
      };
    };

  darwinConfigurations =
    let
      system = "aarch64-darwin";
      unstable = import nixpkgs-unstable {
        config.allowUnfree = true;
        inherit system;
      };
    in
    {
      zelus = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit unstable; };

        modules = [
          home-manager.darwinModules.home-manager
          ./darwin.nix
          ./machines/zelus/configuration.nix
          ./packages.nix
          ./upgrade-diff.nix

          ({ config, ... }: {
            config = {
              nixpkgs.overlays = [
                (import ./overlays)
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
