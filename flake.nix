{
  description = "nixos and macos configurations";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-brave.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Pinned for kokoro: thrift 0.24 in later revisions fails on aarch64-darwin, so the
    # pyarrow chain has no binary cache
    nixpkgs-kokoro.url = "github:NixOS/nixpkgs/774debe7a0d1b496e35677ad955a1011c6ff74f3";
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mattpocockSkills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pvectl = {
      url = "github:davegallant/pvectl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    vpngate = {
      url = "github:davegallant/vpngate";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vermouth = {
      url = "github:dekomote/vermouth";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      darwin,
      home-manager,
      nixpkgs-brave,
      nixpkgs,
      nixpkgs-unstable,
      pvectl,
      vpngate,
      ...
    }@inputs:
    let
      inherit (inputs) mattpocockSkills superpowers;
      nixpkgsConfig = {
        allowUnfree = true;
      };

      mkPkgs =
        input: system:
        import input {
          inherit system;
          config = nixpkgsConfig;
        };
      mkUnstable = mkPkgs nixpkgs-unstable;
      mkBravePkgs = mkPkgs nixpkgs-brave;

      mkSharedModules =
        {
          username,
          unstable,
          bravePkgs,
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
                ];
                extraSpecialArgs = {
                  inherit (inputs) nixpkgs-kokoro;
                  inherit
                    unstable
                    bravePkgs
                    hostname
                    mattpocockSkills
                    pvectl
                    superpowers
                    vpngate
                    ;
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
            "aarch64-darwin"
          ]
          (
            system:
            f {
              inherit system;
              pkgs = mkPkgs nixpkgs system;
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
              # update-hashes.sh uses GNU `sed -i`; macOS ships BSD sed.
              gnused
              just
              nixfmt
              # runs the pi extension tests (`just test`)
              nodejs
              shellcheck
              shfmt
              # Upstream snapshot tests are broken in nixpkgs 26.05; skip checks.
              (statix.overrideAttrs { doCheck = false; })
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
              bravePkgs = mkBravePkgs system;
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
                  bravePkgs
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
          bravePkgs = null;
          mkDarwin =
            { hostname, username }:
            darwin.lib.darwinSystem {
              inherit system;
              specialArgs = {
                inherit
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
                  bravePkgs
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
