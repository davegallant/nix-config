# nix-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This repo stores nix to manage my machines. The initial structure was inspired by [samuelgrf/nixos-config](https://gitlab.com/samuelgrf/nixos-config/-/tree/master/).

## Setup

```console
$ git clone git@github.com:davegallant/nix-config.git
$ cd nix-config
$ sudo ./nixos-rebuild.sh switch
```

## Update

`nix flake update` does not update the [flake.lock](./flake.lock). There is an open issue [here](https://github.com/NixOS/nix/issues/3781).

To update `flake.lock`, run:

```console
$ nix flake update --recreate-lock-file
```
