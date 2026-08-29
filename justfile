set export

alias r := rebuild
alias f := fmt

arch := `uname -s`

# Activation runs under a single `sudo <rebuild>` so it matches the one
# NOPASSWD sudoers rule in nixos.nix (see security.sudo-rs.extraRules).
cmd := if arch == "Linux" { "sudo nixos-rebuild" } else { "sudo darwin-rebuild" }
# Building stays unprivileged on Linux so ./result stays owned by the user.
build_cmd := if arch == "Linux" { "nixos-rebuild" } else { "sudo darwin-rebuild" }
switch_cmd := if arch == "Linux" { "sudo nixos-rebuild switch --flake . --option warn-dirty false" } else { "sudo nix-env -p /nix/var/nix/profiles/system --set ./result && sudo ./result/activate" }

# list available recipes
[private]
default:
  @just --list

# build, show nvd diff, then switch
rebuild:
  $build_cmd build --flake . --option warn-dirty false
  nvd diff /run/current-system result | rg -v '^[<>]{3} ' > /tmp/nvd-diff.txt
  sh -c "$switch_cmd"

# rebuild and install bootloader
rebuild-boot:
  $cmd boot --flake . --install-bootloader

# switch to previous generation
rollback:
  $cmd switch --rollback --flake .

# format all nix files
fmt:
  fd -e nix -x nixfmt

# check formatting without rewriting (`nix run .#formatter` needs a system suffix)
fmt-check:
  fd -e nix -x nixfmt --check

# lint nix files (dead code + anti-patterns) and shell scripts, tracked or not
lint:
  deadnix --fail .
  statix check .
  # --others also covers new scripts that git does not track yet
  shellcheck $(git ls-files --cached --others --exclude-standard '*.sh')

# print which hosts are linux vs darwin (authoritative, from flake.nix)
hosts:
  @nix eval --raw --impure --expr 'let f = builtins.getFlake (toString ./.); in "linux:  " + builtins.concatStringsSep " " (builtins.attrNames f.nixosConfigurations) + "\ndarwin: " + builtins.concatStringsSep " " (builtins.attrNames f.darwinConfigurations) + "\n"'

# eval a host's system closure without building; defaults to the current host
eval-host host=`hostname -s`:
  #!/usr/bin/env bash
  set -euo pipefail
  # the flake only sees git-tracked files; an unstaged new module evaluates as absent
  untracked=$(git ls-files --others --exclude-standard '*.nix')
  if [ -n "$untracked" ]; then
    echo "warning: untracked .nix files are invisible to the flake; 'git add' them first:" >&2
    echo "$untracked" | sed 's/^/  /' >&2
  fi
  if [ "$(uname -s)" = "Linux" ]; then attr=nixosConfigurations; else attr=darwinConfigurations; fi
  nix eval --raw ".#${attr}.{{host}}.config.system.build.toplevel.drvPath" --option warn-dirty false
  echo

# run nix garbage collection (user + root)
clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d

# update version and hashes in home/claude/package.nix
# usage: just update-claude [VERSION]  (VERSION without leading 'v'; defaults to latest)
update-claude *version:
  @./home/claude/update-hashes.sh {{version}}

# update version and hashes in home/pi/package.nix
# usage: just update-pi [VERSION]  (VERSION without leading 'v'; defaults to latest)
update-pi *version:
  @./home/pi/update-hashes.sh {{version}}

# update version and hash in home/codex/package.nix
# usage: just update-codex [VERSION]  (VERSION without leading 'rust-v'; defaults to latest)
update-codex *version:
  @./home/codex/update-hashes.sh {{version}}

# update version, url, hash and plugin cache in pkgs/chatgpt.nix
# usage: just update-chatgpt [VERSION]  (defaults to the latest in the OpenAI deb repo)
update-chatgpt *version:
  @./pkgs/update-chatgpt.sh {{version}}

# update pvectl flake input to latest and rebuild
update-pvectl:
  nix flake lock --update-input pvectl
  just rebuild

# update the Superpowers flake input and activate its skills
update-superpowers:
  nix flake lock --update-input superpowers
  just rebuild

# squash-merge current branch's PR with nvd diff in body
merge-pr:
  #!/usr/bin/env bash
  set -euo pipefail
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  PR=$(gh pr view "$BRANCH" --json number --jq '.number' 2>/dev/null || echo "")
  if [[ -z "$PR" ]]; then
      echo "No PR found for branch $BRANCH"
      exit 1
  fi
  DIFF=$(cat /tmp/nvd-diff.txt 2>/dev/null || echo "")
  BODY_FILE=$(mktemp)
  if [[ -n "$DIFF" ]]; then
      printf '## nvd diff\n```\n%s\n```\n' "$DIFF" > "$BODY_FILE"
  else
      printf 'No package changes detected\n' > "$BODY_FILE"
  fi
  gh pr merge "$PR" --squash --body-file "$BODY_FILE" --delete-branch
  rm "$BODY_FILE"
