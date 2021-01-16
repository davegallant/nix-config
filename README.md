# nix-config

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

This repo stores nix expressions to manage my machines.

## Setup

## git

Clone this as a bare repo to avoid the need for symlinking:

```console
$ git clone --bare git@github.com:davegallant/nix-config.git $HOME/.dotfiles
$ alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # add alias to a .bashrc / .zshrc
$ config config --local status.showUntrackedFiles no
$ config checkout -f # this will overwrite any existing configs in the home directory
```

## home manager

Install [nix](https://nixos.org/guides/install-nix.html) and [home-manager](https://github.com/nix-community/home-manager).

```console
$ home-manager -f ~/nix/home.nix switch
```
