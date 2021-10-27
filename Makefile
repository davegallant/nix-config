SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

HOSTAME ?= $(shell hostname)
UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Linux)
	SWITCH_CMD := sudo nixos-rebuild -I nixos-config="machines/$(HOSTNAME)/configuration.nix" switch --flake '.\#'
endif
ifeq ($(UNAME_S),Darwin)
	SWITCH_CMD := exec darwin-rebuild switch --flake .
endif

switch:
	$(SWITCH_CMD)

update:
	nix flake update
