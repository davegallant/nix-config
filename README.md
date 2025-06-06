# nix-config

This repo stores nix configuration to manage my hosts running [NixOS](https://nixos.org/) and macOS.

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a personal workstation or a server environment.

## Prerequisites

- [Determinate Nix](https://determinate.systems/nix-installer)
- [just](https://github.com/casey/just)

## Build

To run a build/rebuild:

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

Run `nix develop` to install the pre-commit hooks.
