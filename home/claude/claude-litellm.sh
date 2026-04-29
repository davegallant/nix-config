#!/usr/bin/env bash
set -euo pipefail

base="${LITELLM_BASE_URL:-${ANTHROPIC_BASE_URL:-http://127.0.0.1:4000}}"
token="${LITELLM_API_KEY:-${ANTHROPIC_AUTH_TOKEN:-sk-noauth}}"

models_json=$(curl -s -f -m 5 -H "Authorization: Bearer $token" "$base/v1/models") || {
  echo "error: litellm not reachable at $base" >&2
  exit 1
}

model=$(echo "$models_json" |
  jq -r '.data[].id' |
  fzf --prompt='litellm model> ' --height=40%)

[[ -z "$model" ]] && exit 1

export ANTHROPIC_BASE_URL="$base"
export ANTHROPIC_AUTH_TOKEN="$token"
export ANTHROPIC_DEFAULT_SONNET_MODEL="$model"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="$model"
export ANTHROPIC_DEFAULT_OPUS_MODEL="$model"
export CLAUDE_CODE_SUBAGENT_MODEL="$model"

exec claude --model "$model" "$@"
