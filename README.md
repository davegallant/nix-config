# nix-config

This repo stores nix to manage my machines running [NixOS](https://nixos.org/) and macOS.

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a personal workstation or a server environment.

## Setup

> on macOS: install the latest unstable nix from https://github.com/numtide/nix-unstable-installer (for nix flakes),
> and nix-darwin: https://github.com/LnL7/nix-darwin

To run a rebuild:

```sh
make
```

## Update

To update nixpkgs defined in [flake.nix](./flake.nix), run:

```sh
make update
```

If there are updates, they should be reflected in [flake.lock](./flake.lock).

## Rollback

To rollback to the previous generation:

```sh
make rollback
```

## Pre-commit hooks

Pre-commit hooks are automatically activated when [direnv](https://github.com/direnv/direnv) is installed.
