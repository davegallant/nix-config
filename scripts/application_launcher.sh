#!/usr/bin/env bash

# Dependencies:
# - alacritty
# - fzf
# - https://github.com/Biont/sway-launcher-desktop

# Ensure that nix applications are discovered
PATH=$PATH:$HOME/.nix-profile/bin

alacritty \
	--dimensions 80 20 \
	-e env \
	GLYPH_COMMAND="" \
	GLYPH_DESKTOP="" \
	GLYPH_PROMPT="? " \
	TERMINAL_COMMAND=alacritty \
	/usr/bin/sway-launcher-desktop
