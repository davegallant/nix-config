#!/usr/bin/env bash
set -euo pipefail

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
# Input tokens used only for precise context percentage
input_tokens=$(echo "$input" | jq -r '
  [.context_window.current_usage.input_tokens,
   .context_window.current_usage.cache_creation_input_tokens,
   .context_window.current_usage.cache_read_input_tokens]
  | map(. // 0) | add' 2>/dev/null)
if [ -z "$input_tokens" ] || [ "$input_tokens" = "null" ] || [ "$input_tokens" = "0" ]; then
    input_tokens=""
fi
# Compute precise percentage from actual tokens
if [ -n "$input_tokens" ] && [ -n "$window_size" ] && [ "$window_size" != "0" ]; then
    used=$(awk "BEGIN { printf \"%.4f\", $input_tokens / $window_size * 100 }")
else
    used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
fi

# Show only the git repo base name, or fall back to basename of cwd
if git -C "$cwd" rev-parse --show-toplevel > /dev/null 2>&1; then
    short_cwd=$(basename "$(git -C "$cwd" rev-parse --show-toplevel)")
else
    short_cwd=$(basename "$cwd")
fi

# Get git branch (skip optional locks)
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" -c core.fsmonitor=false rev-parse --short HEAD 2>/dev/null)
fi

# Build the status line
parts=()

# Directory (cyan)
parts+=("$(printf '\033[36m%s\033[0m' "$short_cwd")")

# Git branch (magenta)
if [ -n "$git_branch" ]; then
    parts+=("$(printf '\033[35m(%s)\033[0m' "$git_branch")")
fi

# Model (yellow)
if [ -n "$model" ]; then
    parts+=("$(printf '\033[33m%s\033[0m' "$model")")
fi

# Session cost (green)
if [ -n "$session_cost" ]; then
    cost_display=$(awk "BEGIN { printf \"%.4f\", $session_cost }")
    parts+=("$(printf '\033[32m$%s\033[0m' "$cost_display")")
fi

# Context usage — block progress bar + percentage/limit label (e.g. [▓▓▓░░░░░░░] 12%/200k)
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    used_display=$(printf '%.0f' "$used")
    if [ "$used_int" -ge 75 ]; then
        color='\033[31m'  # red
    elif [ "$used_int" -ge 50 ]; then
        color='\033[33m'  # yellow
    else
        color='\033[34m'  # blue
    fi
    filled=$(( used_int / 10 ))
    empty=$(( 10 - filled ))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done
    limit_label=""
    if [ -n "$window_size" ] && [ "$window_size" != "0" ]; then
        if awk "BEGIN { exit !($window_size >= 1000000) }"; then
            limit_label=$(awk "BEGIN { printf \"/%.0fM\", $window_size/1000000 }")
        else
            limit_label=$(awk "BEGIN { printf \"/%.0fk\", $window_size/1000 }")
        fi
    fi
    parts+=("$(printf "${color}[%s] %s%%\033[0m\033[2m%s\033[0m" "$bar" "$used_display" "$limit_label")")
fi

printf '%s' "$(IFS=' '; echo "${parts[*]}")"
