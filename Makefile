SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

HOSTNAME ?= $(shell hostname)
UNAME_S := $(shell uname -s)

export NIXPKGS_ALLOW_UNFREE := 1

ifeq ($(UNAME_S),Linux)
	SWITCH_CMD := nixos-rebuild --use-remote-sudo -I nixos-config="modules/machines/$(HOSTNAME)/configuration.nix" switch --flake '.\#' \
								--impure # Impure because of: https://discourse.nixos.org/t/vscode-remote-wsl-extension-works-on-nixos-without-patching-thanks-to-nix-ld/14615
endif
ifeq ($(UNAME_S),Darwin)
	SWITCH_CMD := exec darwin-rebuild switch --flake .
endif

switch:
	$(SWITCH_CMD)

rollback:
	nixos-rebuild --use-remote-sudo switch --rollback -I nixos-config="modules/machines/$(HOSTNAME)/configuration.nix"

update:
	nix flake update
	make
	git add .
	git commit -S -m "nix flake update: $$(TZ=UTC date '+%Y-%m-%d %H:%M:%S %Z')"
	git push

fmt:
	alejandra .
