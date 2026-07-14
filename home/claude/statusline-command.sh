#!/usr/bin/env bash
# Resilient by design: a statusline must always render something, so we avoid
# `set -e` — a missing or malformed field degrades to a shorter line, never a
# blank one (or a jq parse error leaking through).
set -uo pipefail

input=$(cat)

# Parse every field in a single jq pass. Fields are joined with US (0x1f),
# generated in bash and passed via --arg. A non-whitespace separator stops
# `read` from collapsing the runs that empty fields would create with tabs/
# spaces, which would otherwise shift every later value into the wrong variable.
# Absent values become "" (not `empty`) so the field count stays fixed.
us=$'\x1f'
IFS=$us read -r cwd model window_size input_tokens used_pct < <(
  jq --arg us "$us" -r '
    [ (.workspace.current_dir // .cwd // ""),
      (.model.display_name // ""),
      (.context_window.context_window_size // ""),
      ([ .context_window.current_usage.input_tokens,
         .context_window.current_usage.cache_creation_input_tokens,
         .context_window.current_usage.cache_read_input_tokens ] | map(. // 0) | add),
      (.context_window.used_percentage // "")
    ] | map(tostring) | join($us)' <<<"$input" 2>/dev/null
)

# A zero/absent token sum means we have no precise figure to work from.
if [ -z "$input_tokens" ] || [ "$input_tokens" = "null" ] || [ "$input_tokens" = "0" ]; then
    input_tokens=""
fi

# Prefer a precise percentage computed from actual tokens; otherwise use the
# percentage the host reported.
if [ -n "$input_tokens" ] && [ -n "$window_size" ] && [ "$window_size" != "0" ]; then
    used=$(awk -v t="$input_tokens" -v w="$window_size" 'BEGIN { printf "%.4f", t / w * 100 }')
else
    used="$used_pct"
fi

# Show only the git repo base name, or fall back to basename of cwd. A toplevel
# result also proves we're in a work tree, so reuse it to gate the branch lookup.
toplevel=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)
short_cwd=$(basename "${toplevel:-$cwd}")

# Git branch (skip optional locks via fsmonitor=false)
git_branch=""
if [ -n "$toplevel" ]; then
    git_branch=$(git -C "$cwd" -c core.fsmonitor=false symbolic-ref --short HEAD 2>/dev/null \
        || git -C "$cwd" -c core.fsmonitor=false rev-parse --short HEAD 2>/dev/null || true)
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

# Context usage — block progress bar + percentage/limit label (e.g. [▓▓▓░░░░░░░] 12%/200k)
if [ -n "$used" ]; then
    used_int=$(printf '%.0f' "$used")
    if [ "$used_int" -ge 75 ]; then
        color='\033[31m'  # red
    elif [ "$used_int" -ge 50 ]; then
        color='\033[33m'  # yellow
    else
        color='\033[34m'  # blue
    fi
    filled=$(( used_int / 10 ))
    (( filled > 10 )) && filled=10   # clamp so an over-budget context can't overflow the bar
    empty=$(( 10 - filled ))
    bar=""
    for ((i=0; i<filled; i++)); do bar+="▓"; done
    for ((i=0; i<empty; i++));  do bar+="░"; done
    limit_label=""
    if [ -n "$window_size" ] && [ "$window_size" != "0" ]; then
        ws_int=${window_size%%.*}
        if [ "$ws_int" -ge 1000000 ]; then
            limit_label="/$(( ws_int / 1000000 ))M"
        else
            limit_label="/$(( ws_int / 1000 ))k"
        fi
    fi
    parts+=("$(printf "${color}[%s] %s%%\033[0m\033[2m%s\033[0m" "$bar" "$used_int" "$limit_label")")
fi

(IFS=' '; printf '%s' "${parts[*]}")
