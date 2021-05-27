#!/usr/bin/env bash
cd "$(dirname "$0")" || exit
exec nixos-rebuild -I nixos-config="machines/$(hostname)/configuration.nix" "$@" --flake '.#'
