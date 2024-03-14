set export

host := `hostname`

build-linux:
	nixos-rebuild --use-remote-sudo -I nixos-config=machines/$host/configuration.nix switch --flake .

build-mac:
	darwin-rebuild switch --flake .

rollback:
	nixos-rebuild --use-remote-sudo switch --rollback -I nixos-config="machines/$host/configuration.nix"

update:
	@./nix-flake-update.sh

fmt:
	nixpkgs-fmt .
