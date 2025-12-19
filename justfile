set export

alias u := update
alias r := rebuild

arch := `uname -s`

cmd := if arch == "Linux" { "nixos-rebuild --sudo" } else { "darwin-rebuild" }

rebuild:
  $cmd switch --flake .

rebuild-boot:
  $cmd boot --flake . --install-bootloader

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
