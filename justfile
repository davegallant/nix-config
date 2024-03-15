set export

config := "machines/$(hostname)/configuration.nix"

build-linux:
  nixos-rebuild --use-remote-sudo -I nixos-config=$config switch --flake .

build-mac:
	darwin-rebuild switch -I nixos-config=$config --flake .

rollback-linux:
  nixos-rebuild --use-remote-sudo switch --rollback -I nixos-config=$config

rollback-mac:
  darwin-rebuild --rollback -I nixos-config=$config

update:
  @./nix-flake-update.sh

fmt:
  nixpkgs-fmt .

clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d
