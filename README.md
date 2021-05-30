# nix-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This repo stores nix to manage my machines running both [NixOS](https://nixos.org/) and macOS. The initial structure was inspired by [samuelgrf/nixos-config](https://gitlab.com/samuelgrf/nixos-config/-/tree/master/).

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a desktop or a server.

## Setup

### NixOS

```sh
sudo ./rebuild.sh switch
```

### macOS

1. Install the latest unstable nix from https://github.com/numtide/nix-unstable-installer (to get nix flakes)
1. Install nix-darwin: https://github.com/LnL7/nix-darwin
1. Add home-manager channel: `nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager; nix-channel --update` (TODO: this requirement should be removed in the future)

```sh
./rebuild.sh switch
```

## Update

To update nixpkgs defined in [flake.nix](./flake.nix), run:

```sh
nix flake update
```

If there are updates, they should be reflected in [flake.lock](./flake.lock).

## Pre-commit hooks

Pre-commit hooks are automatically activated when [direnv](https://github.com/direnv/direnv) is installed.
