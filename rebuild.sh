#!/usr/bin/env bash

cd "$(dirname "$0")" || exit

uname="$(uname -s)"
case "${uname}" in
    Linux*)     machine=linux;;
    Darwin*)    machine=mac;;
    *)          machine="unknown"
esac

if [[ "$machine" ==  "linux" ]]; then
    exec nixos-rebuild -I nixos-config="machines/$(hostname)/configuration.nix" "$@" --flake '.#'
elif [[ "$machine" ==  "mac" ]]; then
    exec darwin-rebuild "$@" --flake . --impure # TODO: What is causing this impurity?
else 
    echo 'Unsupported OS.'
    echo 'Exiting...'
    exit 1
fi
