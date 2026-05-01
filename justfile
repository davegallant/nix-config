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

# update version and hashes in home/claude/package.nix
# usage: just update-claude [VERSION]  (VERSION without leading 'v'; defaults to latest)
update-claude *version:
  @./home/claude/update-hashes.sh {{version}}

# update version and hashes in home/opencode/package.nix
# usage: just update-opencode [VERSION]  (VERSION without leading 'v'; defaults to latest)
update-opencode *version:
  @./home/opencode/update-hashes.sh {{version}}

# fetch live model metadata from the litellm proxy and write a json file
# consumed by home/opencode.nix. file path:
#   ~/.config/nix-config/litellm-models.json
refresh-models:
  #!/usr/bin/env bash
  set -euo pipefail
  url="${LITELLM_BASE_URL:-${ANTHROPIC_BASE_URL:-http://127.0.0.1:4000/v1}}"
  key="${LITELLM_API_KEY:-${ANTHROPIC_AUTH_TOKEN:-sk-noauth}}"
  out="$HOME/.config/nix-config/litellm-models.json"
  mkdir -p "$(dirname "$out")"
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  echo "fetching models from $url/model/info"
  curl -fsS -m 10 -H "Authorization: Bearer $key" "$url/model/info" \
    | jq '
      def num($x): if ($x == null) then 0 else $x end;
      def per_million($x): (num($x) * 1000000 * 10000 | round) / 10000;
      # dedupe by model_name (first wins; litellm exposes the same name across multiple routes)
      [.data[]] | unique_by(.model_name)
      | map({
          key: .model_name,
          value: {
            name: .model_name,
            attachment: (.model_info.supports_vision == true),
            reasoning: (.model_info.supports_reasoning == true),
            tool_call: (.model_info.supports_function_calling == true),
            limit: {
              context: num(.model_info.max_input_tokens),
              output: num(.model_info.max_output_tokens),
            },
            cost: {
              input: per_million(.model_info.input_cost_per_token),
              output: per_million(.model_info.output_cost_per_token),
            },
          },
        })
      | from_entries
    ' > "$tmp"
  mv "$tmp" "$out"
  echo "wrote $(jq 'length' "$out") models to $out"
