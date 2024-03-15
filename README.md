# nix-config

This repo stores nix to manage my machines running [NixOS](https://nixos.org/) and macOS.

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a personal workstation or a server environment.

## Setup

> on macOS: install the latest unstable nix from https://github.com/numtide/nix-unstable-installer (for nix flakes),
> and nix-darwin: https://github.com/LnL7/nix-darwin

Recipes are stored in a justfile. [just](https://github.com/casey/just) is required.

To run a rebuild:

```sh
just rebuild
```

## Update

To update nixpkgs defined in [flake.nix](./flake.nix), run:

```sh
just update
```

If there are updates, they should be reflected in [flake.lock](./flake.lock).

## Rollback

To rollback to the previous generation:

```sh
just rollback
```

## Garbage collection

To cleanup previous files, run nix garbage collection:

```sh
just clean
```

## Pre-commit hooks

Pre-commit hooks are automatically activated when [direnv](https://github.com/direnv/direnv) is installed.
