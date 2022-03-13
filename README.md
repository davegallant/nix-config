# nix-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This repo stores nix to manage my machines running both [NixOS](https://nixos.org/) and macOS.

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

## Pre-commit hooks

Pre-commit hooks are automatically activated when [direnv](https://github.com/direnv/direnv) is installed.

## Encryption

Overly sensitive configuration is encrypted with [git-crypt](https://www.agwa.name/projects/git-crypt/).
