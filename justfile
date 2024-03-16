set export

alias u := update

arch := `uname -s`

cmd := if arch == "Linux" { "nixos-rebuild --use-remote-sudo" } else { "darwin-rebuild" }

rebuild:
  $cmd switch --flake . -I nixos-config="machines/$(hostname)/configuration.nix"

rollback:
  $cmd switch --rollback --flake .

update:
  @./nix-flake-update.sh

fmt:
  nixpkgs-fmt .

clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d
