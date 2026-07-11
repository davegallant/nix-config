#!/usr/bin/env bash
# Never blocks session start: this is best-effort, so every failure path
# degrades to a silent no-op rather than a hook error.
set -uo pipefail

input=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)
[ -z "$cwd" ] && exit 0

vault_root="$HOME/@vaultAiDir@"
[ -d "$vault_root" ] || exit 0

# Mirrors Claude Code's own project-path encoding: cwd with every "/" and "."
# turned into "-", used to derive ~/.claude/projects/<encoded>/memory.
encoded=$(echo "$cwd" | sed 's/[\/.]/-/g')
memory_dir="$HOME/.claude/projects/$encoded/memory"

# Already migrated (or manually symlinked) -> nothing to do.
[ -L "$memory_dir" ] && exit 0

vault_dir="$vault_root/$(basename "$cwd")"
mkdir -p "$vault_dir" "$(dirname "$memory_dir")" 2>/dev/null || exit 0

if [ -d "$memory_dir" ]; then
    find "$memory_dir" -mindepth 1 -maxdepth 1 -exec mv {} "$vault_dir"/ \; 2>/dev/null
    rmdir "$memory_dir" 2>/dev/null
fi

ln -s "$vault_dir" "$memory_dir" 2>/dev/null
exit 0
