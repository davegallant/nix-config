{
  description = "nixos and macos configurations";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-ld.url = "github:Mic92/nix-ld";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {...} @ args: import ./outputs.nix args;
}
