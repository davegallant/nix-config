set export

host := `hostname`

build-linux:
	nixos-rebuild --use-remote-sudo -I nixos-config=machines/$host/configuration.nix switch --flake .

build-mac:
	darwin-rebuild switch -I nixos-config="machines/$host/configuration.nix" --flake .

rollback:
	nixos-rebuild --use-remote-sudo switch --rollback -I nixos-config="machines/$host/configuration.nix"

update:
	@./nix-flake-update.sh

fmt:
	nixpkgs-fmt .

clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d
