# nix-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This repo stores nix to manage my machines running [NixOS](https://nixos.org/). The initial structure was inspired by [samuelgrf/nixos-config](https://gitlab.com/samuelgrf/nixos-config/-/tree/master/).

The configuration is very specific to my own machines and setup, but it may be a useful reference for anyone else learning or experimenting with nix, whether it be on a desktop or a server.

## Setup

```console
$ git clone git@github.com:davegallant/nix-config.git
$ cd nix-config
$ sudo ./rebuild.sh switch
```

## Update

To update nixpkgs defined in [flake.nix](./flake.nix), run:

```console
$ nix flake update
```

If there are updates, they should be reflected in [flake.lock](./flake.lock).

## Pre-commit hooks

Pre-commit hooks are automatically activated when [direnv](https://github.com/direnv/direnv) is installed.
