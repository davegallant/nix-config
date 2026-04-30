set export

alias u := update
alias r := rebuild

arch := `uname -s`

cmd := if arch == "Linux" { "nixos-rebuild --sudo" } else { "sudo darwin-rebuild" }

rebuild:
  $cmd switch --flake . --option warn-dirty false

rebuild-boot:
  $cmd boot --flake . --install-bootloader

rollback:
  $cmd switch --rollback

update: fmt
  @./update-flake.sh

fmt:
  fd -e nix -x nixfmt

clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d
