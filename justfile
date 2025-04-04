set export

alias u := update
alias r := rebuild

arch := `uname -s`

cmd := if arch == "Linux" { "nixos-rebuild --use-remote-sudo" } else { "darwin-rebuild" }

rebuild:
  $cmd switch --show-trace --flake . -I nixos-config="machines/$(hostname)/configuration.nix"

rollback:
  $cmd switch --rollback --flake .

channel-update:
  nix-channel --update
  sudo nix-channel --update

update:
  @./nix-flake-update.sh

fmt:
  nixfmt .

clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d
