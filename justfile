set export

alias r := rebuild
alias f := fmt

arch := `uname -s`

cmd := if arch == "Linux" { "nixos-rebuild --sudo" } else { "sudo darwin-rebuild" }
switch_cmd := if arch == "Linux" { "sudo result/bin/switch-to-configuration switch" } else { "sudo result/activate" }

# list available recipes
[private]
default:
  @just --list

# build, show nvd diff, then switch
rebuild:
  $cmd build --flake . --option warn-dirty false
  nvd diff /run/current-system result | rg -v '^[<>]{3} ' > /tmp/nvd-diff.txt
  $switch_cmd

# rebuild and install bootloader
rebuild-boot:
  $cmd boot --flake . --install-bootloader

# switch to previous generation
rollback:
  $cmd switch --rollback --flake .

# format all nix files
fmt:
  fd -e nix -x nixfmt

# lint nix files (dead code + anti-patterns) and shell scripts
lint:
  deadnix --fail .
  statix check .
  shellcheck $(git ls-files '*.sh')

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
