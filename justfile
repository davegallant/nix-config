set export

config := "machines/$(hostname)/configuration.nix"
arch := `uname -s`

cmd := if arch == "Linux" { "nixos-rebuild --use-remote-sudo" } else { "darwin-rebuild" }

rebuild:
  $cmd switch --flake . -I nixos-config=$config

rollback:
  $cmd switch --rollback -I nixos-config=$config

update:
  @./nix-flake-update.sh

fmt:
  nixpkgs-fmt .

clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d
