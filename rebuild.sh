#!/usr/bin/env bash

cd "$(dirname "$0")" || exit

uname="$(uname -s)"
case "${uname}" in
Linux*) machine=linux ;;
Darwin*) machine=mac ;;
*) machine="unknown" ;;
esac

if [[ "$machine" == "linux" ]]; then
	sudo nixos-rebuild -I nixos-config="machines/$(hostname)/configuration.nix" "$@" --flake '.#'
elif [[ "$machine" == "mac" ]]; then
	exec darwin-rebuild "$@" --flake .
else
	echo 'Unsupported OS.'
	echo 'Exiting...'
	exit 1
fi
