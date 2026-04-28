#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
# Sum all current_usage token fields for precise count
input_tokens=$(echo "$input" | jq -r '
  [.context_window.current_usage.input_tokens,
   .context_window.current_usage.output_tokens,
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

# Format a token count as an exact number with comma separators
fmt_tokens() {
    local n="$1"
    if [ -z "$n" ] || [ "$n" = "null" ]; then echo "?"; return; fi
    printf '%d' "$n" | awk '{
        s = $0; result = ""
        while (length(s) > 3) {
            result = "," substr(s, length(s)-2) result
            s = substr(s, 1, length(s)-3)
        }
        print s result
    }'
}

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

# Git branch (green)
if [ -n "$git_branch" ]; then
    parts+=("$(printf '\033[32m(%s)\033[0m' "$git_branch")")
fi

# Model (yellow)
if [ -n "$model" ]; then
    parts+=("$(printf '\033[33m%s\033[0m' "$model")")
fi

# Session cost (magenta)
if [ -n "$session_cost" ]; then
    cost_display=$(awk "BEGIN { printf \"%.4f\", $session_cost }")
    parts+=("$(printf '\033[35m$%s\033[0m' "$cost_display")")
fi

# Context usage — rendered as a 10-segment block progress bar
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    used_display=$(printf '%.1f' "$used")
    if [ "$used_int" -ge 80 ]; then
        color='\033[31m'  # red
    elif [ "$used_int" -ge 50 ]; then
        color='\033[33m'  # yellow
    else
        color='\033[32m'  # green
    fi
    filled=$(( used_int / 10 ))
    empty=$(( 10 - filled ))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done
    token_label=""
    if [ -n "$input_tokens" ] && [ -n "$window_size" ]; then
        used_fmt=$(fmt_tokens "$input_tokens")
        total_fmt=$(fmt_tokens "$window_size")
        token_label=" ${used_display}% (${used_fmt} / ${total_fmt})"
    fi
    parts+=("$(printf "${color}[%s]%s\033[0m" "$bar" "$token_label")")
fi

printf '%s' "$(IFS=' '; echo "${parts[*]}")"
