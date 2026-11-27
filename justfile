set export

alias r := rebuild
alias f := fmt

arch := `uname -s`

# Activation needs root and prompts for the sudo password.
cmd := if arch == "Linux" { "sudo nixos-rebuild" } else { "sudo darwin-rebuild" }
# Building stays unprivileged on Linux so ./result stays owned by the user.
build_cmd := if arch == "Linux" { "nixos-rebuild" } else { "sudo darwin-rebuild" }
# Per-user location: a fixed name in shared /tmp could be pre-created by another user.
nvd_diff := env('XDG_RUNTIME_DIR', env('TMPDIR', '/tmp')) / 'nvd-diff.txt'
switch_cmd := if arch == "Linux" { "sudo nixos-rebuild switch --flake . --option warn-dirty false" } else { "sudo nix-env -p /nix/var/nix/profiles/system --set ./result && sudo ./result/activate" }

# list available recipes
[private]
default:
  @just --list

# build, show nvd diff, then switch
rebuild:
  $build_cmd build --flake . --option warn-dirty false
  nvd diff /run/current-system result | rg -v '^[<>]{3} ' > "$nvd_diff"
  sh -c "$switch_cmd"

# rebuild and install bootloader
[linux]
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

# run the pi extension tests (Node strips the TypeScript types itself)
test:
  node --test home/pi/tests/*.test.mjs

# everything to run before committing: format check, lint, tests, and eval of every host
check: fmt-check lint test
  # --all-systems: without it a Mac skips hephaestus as an incompatible system
  nix flake check --no-build --all-systems --option warn-dirty false

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
  # look the host up rather than assuming the local OS, so a Mac can eval hephaestus
  attr=""
  for cfg in nixosConfigurations darwinConfigurations; do
    if [ "$(nix eval ".#${cfg}" --apply 'c: c ? "{{host}}"' --option warn-dirty false)" = true ]; then
      attr=$cfg
      break
    fi
  done
  if [ -z "$attr" ]; then
    echo "unknown host '{{host}}'; see 'just hosts'" >&2
    exit 1
  fi
  nix eval --raw ".#${attr}.{{host}}.config.system.build.toplevel.drvPath" --option warn-dirty false
  echo

# run nix garbage collection (user + root)
clean:
  echo 'Cleaning user...'
  nix-collect-garbage -d
  echo 'Cleaning root...'
  sudo nix-collect-garbage -d

# usage: just update-tool TOOL [VERSION]  (VERSION without the tag prefix; defaults to latest)
# update one prebuilt tool's version and hashes; TOOL is its home/ dir name
update-tool tool *version:
  @test -x home/{{tool}}/update-hashes.sh || { echo "unknown tool '{{tool}}'; have:" home/*/update-hashes.sh >&2; exit 1; }
  @./home/{{tool}}/update-hashes.sh {{version}}

# update every prebuilt tool (each home/*/update-hashes.sh) in parallel
update-tools:
  #!/usr/bin/env bash
  set -euo pipefail
  logs=$(mktemp -d)
  trap 'rm -rf "$logs"' EXIT
  tools=() pids=() failed=()
  for script in home/*/update-hashes.sh; do
    tool=$(basename "$(dirname "$script")")
    "$script" >"$logs/$tool" 2>&1 &
    tools+=("$tool") pids+=($!)
  done
  for i in "${!tools[@]}"; do
    status=ok
    wait "${pids[$i]}" || { status=FAILED; failed+=("${tools[$i]}"); }
    echo "== ${tools[$i]} ($status)"
    cat "$logs/${tools[$i]}"
  done
  if ((${#failed[@]})); then echo "failed: ${failed[*]}" >&2; exit 1; fi

# update the agent skill inputs; review the upstream diff before rebuilding
update-skills:
  nix flake update superpowers mattpocockSkills
  git diff flake.lock

# update every flake input except the skills (update-skills) and the pinned kokoro
update-flake:
  #!/usr/bin/env bash
  set -euo pipefail
  mapfile -t inputs < <(jq -r '.nodes.root.inputs | keys[]' flake.lock \
    | grep -Ev '^(mattpocockSkills|nixpkgs-kokoro|superpowers)$')
  nix flake update "${inputs[@]}"

# update flake inputs and prebuilt tools; review the diff, then just check / just rebuild
update: update-flake update-tools
  git diff --stat

# commit the output of `just update` (only the update-touched paths; push stays manual)
commit-update message="chore(deps): update flake inputs and package versions":
  #!/usr/bin/env bash
  set -euo pipefail
  paths=(flake.lock)
  for script in home/*/update-hashes.sh; do paths+=("${script%update-hashes.sh}package.nix"); done
  git diff --stat -- "${paths[@]}"
  read -r -p "Commit the update changes? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || { echo "aborted" >&2; exit 1; }
  git add -- "${paths[@]}"
  git commit -m "{{message}}"

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
  DIFF=$(cat "$nvd_diff" 2>/dev/null || echo "")
  BODY_FILE=$(mktemp)
  if [[ -n "$DIFF" ]]; then
      printf '## nvd diff\n```\n%s\n```\n' "$DIFF" > "$BODY_FILE"
  else
      printf 'No package changes detected\n' > "$BODY_FILE"
  fi
  gh pr merge "$PR" --squash --body-file "$BODY_FILE" --delete-branch
  rm "$BODY_FILE"
