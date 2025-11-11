# nix-config

This repo stores nix configuration to manage my hosts running [NixOS](https://nixos.org/) and macOS.

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a personal workstation or a server environment.

<img width="1903" height="986" alt="Image" src="https://github.com/user-attachments/assets/6cba837c-2b5e-4f6c-803e-dbbde81a8047" />

## Prerequisites

- [NixOS](nixos.org) (Linux)
- [Determinate Nix](https://determinate.systems/nix-installer) (macOS)
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
