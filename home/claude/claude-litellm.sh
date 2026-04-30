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

max_input=$(curl -s -f -m 5 -H "Authorization: Bearer $token" "$base/model/info" 2>/dev/null |
  jq -r --arg m "$model" '[.data[] | select(.model_name == $m) | .model_info.max_input_tokens] | first // empty')

claude_model="$model"
if [[ -n "$max_input" ]]; then
  max_input_k=$((max_input / 1000))
  claude_model="${model}[${max_input_k}k]"
fi

export ANTHROPIC_BASE_URL="$base"
export ANTHROPIC_AUTH_TOKEN="$token"
export ANTHROPIC_DEFAULT_SONNET_MODEL="$claude_model"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="$claude_model"
export ANTHROPIC_DEFAULT_OPUS_MODEL="$claude_model"
export CLAUDE_CODE_SUBAGENT_MODEL="$claude_model"

exec claude --model "$claude_model" "$@"
