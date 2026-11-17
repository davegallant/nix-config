#!/usr/bin/env bash
# Start a new agent session inside a repo and hand it a task, so the session
# is filed under that repo (agora channels key off a session's starting cwd).
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: agent-hop [--agent claude|codex|pi] [--tab|--bg] <owner/repo|path> <prompt>

  --agent  agent to start (default: claude)
  --tab    open a Ghostty tab running the agent (default inside Ghostty on macOS)
  --bg     start a background Claude session (claude only; default elsewhere)

<owner/repo> resolves to ~/src/github.com/<owner>/<repo>, cloned if missing.
The prompt may also be piped on stdin when the argument is "-".
EOF
  exit 2
}

agent=claude
mode=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --agent)
    agent="${2:?$(usage)}"
    shift 2
    ;;
  --tab | --bg)
    mode="${1#--}"
    shift
    ;;
  -h | --help) usage ;;
  --)
    shift
    break
    ;;
  -?*) usage ;;
  *) break ;;
  esac
done

[[ $# -eq 2 ]] || usage
target="$1"
prompt="$2"
[[ "$prompt" == "-" ]] && prompt="$(cat)"
[[ -n "$prompt" ]] || usage

case "$agent" in
claude | codex | pi) ;;
*)
  echo "agent-hop: unknown agent '$agent'" >&2
  exit 2
  ;;
esac

# Resolve the repo directory, cloning owner/repo when it isn't there yet.
if [[ -d "$target" ]]; then
  dir="$(cd "$target" && pwd)"
elif [[ "$target" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  dir="$HOME/src/github.com/$target"
  if [[ ! -d "$dir" ]]; then
    echo "agent-hop: cloning $target → $dir" >&2
    mkdir -p "$(dirname "$dir")"
    gh repo clone "$target" "$dir" >&2
  fi
else
  echo "agent-hop: '$target' is neither a directory nor owner/repo" >&2
  exit 1
fi

can_tab() {
  [[ "$(uname -s)" == Darwin && "${TERM_PROGRAM:-}" == ghostty ]]
}

if [[ -z "$mode" ]]; then
  if can_tab; then mode="tab"; else mode="bg"; fi
fi

open_tab() {
  # Ghostty types `initial input` into the user's shell (fish), so hand it a
  # launcher script path rather than a quoted command line.
  local tmp launcher
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/agent-hop.XXXXXX")"
  printf '%s' "$prompt" >"$tmp/prompt"
  launcher="$tmp/run"
  cat >"$launcher" <<EOF
#!/usr/bin/env bash
cd $(printf '%q' "$dir") || exit 1
prompt="\$(cat $(printf '%q' "$tmp/prompt"))"
rm -rf $(printf '%q' "$tmp")
exec $agent "\$prompt"
EOF
  chmod +x "$launcher"

  osascript - "$dir" "$launcher" <<'EOF' >/dev/null
on run argv
  set {d, c} to argv
  tell application "Ghostty"
    set cfg to {initial working directory:d, initial input:c & linefeed}
    if (count of windows) is 0 then
      new window with configuration cfg
    else
      new tab in front window with configuration cfg
    end if
  end tell
end run
EOF
  echo "agent-hop: opened a Ghostty tab running $agent in $dir"
}

case "$mode" in
tab)
  if ! can_tab; then
    echo "agent-hop: --tab needs Ghostty on macOS" >&2
    exit 1
  fi
  open_tab
  ;;
bg)
  if [[ "$agent" != claude ]]; then
    echo "agent-hop: --bg supports claude only; ask the user to start $agent in $dir" >&2
    exit 1
  fi
  if out="$(cd "$dir" && claude --bg "$prompt" 2>&1)"; then
    printf '%s\n' "$out"
  elif grep -q 'not trusted' <<<"$out" && can_tab; then
    echo "agent-hop: $dir is not trusted yet; opening a tab so the user can accept" >&2
    open_tab
  else
    printf '%s\n' "$out" >&2
    exit 1
  fi
  ;;
esac
