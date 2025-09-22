set export

alias u := update
alias r := rebuild

arch := `uname -s`

cmd := if arch == "Linux" { "nixos-rebuild --use-remote-sudo" } else { "darwin-rebuild" }

rebuild:
  sudo $cmd switch --flake . -I nixos-config="hosts/$(hostname).nix"

rollback:
  sudo $cmd switch --rollback --flake .

channel-update:
  nix-channel --update
  sudo nix-channel --update

update:
  @./update-flake.sh

fmt:
  nixfmt *.nix

clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d
