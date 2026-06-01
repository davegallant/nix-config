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

# lint nix files (dead code + anti-patterns)
lint:
  deadnix --fail .
  statix check .

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

# fetch live model metadata from the litellm proxy and write a json file
#   ~/.config/nix-config/litellm-models.json
# uses /v1/models for the list of available models and /public/litellm_model_cost_map
# (no auth) for pricing and capabilities.
refresh-models:
  #!/usr/bin/env bash
  set -euo pipefail
  url="${LITELLM_BASE_URL:-${ANTHROPIC_BASE_URL:-http://127.0.0.1:4000/v1}}"
  key="${LITELLM_API_KEY:-${ANTHROPIC_AUTH_TOKEN:-sk-noauth}}"
  root="${url%/v1}"; root="${root%/}"
  out="$HOME/.config/nix-config/litellm-models.json"
  mkdir -p "$(dirname "$out")"
  models_tmp="$(mktemp)"; costs_tmp="$(mktemp)"
  trap 'rm -f "$models_tmp" "$costs_tmp"' EXIT

  curl -fsS -m 10 -H "Authorization: Bearer $key" "$root/v1/models" > "$models_tmp"
  curl -fsS -m 30 "$root/public/litellm_model_cost_map" > "$costs_tmp"

  jq -n --slurpfile models "$models_tmp" --slurpfile costs "$costs_tmp" '
      def num($x): $x // 0;
      def per_million($x): (num($x) * 1000000 * 10000 | round) / 10000;
      ($costs[0]) as $cost_map
      | [$models[0].data[].id] | unique
      | map(. as $name | ($cost_map[$name] // {}) as $c | {
          key: $name,
          value: {
            name: $name,
            attachment: ($c.supports_vision == true),
            reasoning: ($c.supports_reasoning == true),
            tool_call: ($c.supports_function_calling == true),
            limit: { context: num($c.max_input_tokens), output: num($c.max_output_tokens) },
            cost:  { input:   per_million($c.input_cost_per_token), output: per_million($c.output_cost_per_token) },
          },
        })
      | from_entries
    ' > "$out.tmp"
  mv "$out.tmp" "$out"
  echo "wrote $(jq 'length' "$out") models to $out"

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
