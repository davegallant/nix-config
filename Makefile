SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

HOSTNAME ?= $(shell hostname)
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
	SWITCH_CMD := nixos-rebuild --use-remote-sudo -I nixos-config="modules/machines/$(HOSTNAME)/configuration.nix" switch --flake '.\#'
endif
ifeq ($(UNAME_S),Darwin)
	SWITCH_CMD := exec darwin-rebuild switch --flake .
endif

switch:
	$(SWITCH_CMD)

rollback:
	nixos-rebuild --use-remote-sudo switch --rollback -I nixos-config="modules/machines/$(HOSTNAME)/configuration.nix"

update:
	@./nix-flake-update.sh

fmt:
	alejandra .
