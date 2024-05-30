{
  description = "nixos and macos configurations";

  inputs = {
    darwin.url = "github:lnl7/nix-darwin";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixvim.url = "github:nix-community/nixvim/nixos-23.11";
    stylix.url = "github:danth/stylix/release-23.11";
  };

  outputs =
    { self
    , darwin
    , home-manager
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , stylix
    , ...
    } @ inputs: {
      nixosConfigurations =
        let
          unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
            config.permittedInsecurePackages = [ ];
          };
        in
        {
          hephaestus = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit unstable; };
            modules =
              [
                ./fonts.nix
                ./machines/hephaestus/configuration.nix
                ./packages.nix
                ./services/netdata/default.nix
                ./upgrade-diff.nix
                home-manager.nixosModules.home-manager
                stylix.nixosModules.stylix

                ({ config
                 , lib
                 , ...
                 }: {
                  config = {
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
              stylix.darwinModules.stylix
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
    };
}
