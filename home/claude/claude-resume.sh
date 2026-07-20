#!/usr/bin/env bash
#
# Browse Claude Code sessions across ALL projects with fzf.
#
# Each session is stored as ~/.claude/projects/<encoded-dir>/<session-id>.jsonl.
# The real working directory is not derivable from the (lossy) encoded dir name,
# so we read the `cwd` field embedded in the transcript instead.
#
# On selection this prints a single line "<cwd>\t<session-id>" to stdout and
# exits 0. It prints nothing (and still exits 0) if the picker is cancelled.
# The caller (the `cr` fish function) does the `cd` + `claude --resume`, since a
# child process cannot change its parent shell's directory.

set -euo pipefail

projects="$HOME/.claude/projects"

# Portable mtime-in-epoch-seconds (GNU coreutils vs BSD/macOS stat).
mtime() { stat -c %Y -- "$1" 2>/dev/null || stat -f %m -- "$1"; }

# jq program: fed ONE session file as a raw string (-Rrs), plus --argjson mtime
# and --arg path. Emits one TAB-separated row:
#
#     <mtime>\t<session-id>\t<cwd>\t<display>
#
# where <display> is "<age>  <project>  <title-or-first-prompt>". Living in a
# single-quoted heredoc means this is plain jq -- no shell/nix escaping.
read -r -d '' jq_row <<'JQ' || true
  def clean: gsub("\\s+"; " ") | sub("^ "; "") | sub(" $"; "");

  # Message content is sometimes a plain string, sometimes an array of blocks.
  def message_text(m):
    (m.content // "")
    | if   type == "string" then .
      elif type == "array"  then [ .[] | select(.type == "text") | .text ] | join(" ")
      else "" end;

  # Slash-commands, tool results, caveats and reminders make poor labels.
  def is_noise($t):
    $t == "" or ($t | test("^(<local-command|<command-|Caveat:|<bash-|<user-|<system-reminder>)"));

  def rpad($s; $w): ($s[0:$w]) as $x | $x + ((" " * ($w - ($x | length))) // "");
  def lpad($s; $w): ((" " * ($w - ($s | length))) // "") + $s;

  # Parse the transcript, skipping any line that is not valid JSON.
  [ split("\n")[] | select(length > 0) | fromjson? ] as $rows

  # Working directory: first entry that carries one.
  | ( [ $rows[] | select(.cwd) ][0].cwd // "" ) as $cwd

  # Label: prefer Claude's own recap title (the latest one it wrote), then fall
  # back to the first genuine user prompt, then a placeholder.
  | ( [ $rows[]
        | select(.type == "ai-title")
        | .aiTitle
        | select(. != null and . != "") ] | last // "" ) as $title
  | ( [ $rows[]
        | select(.type == "user" and (.isMeta | not))
        | (message_text(.message) | clean)
        | select(. != "" and (is_noise(.) | not)) ][0] // "" ) as $prompt
  | ( if   $title  != "" then $title
      elif $prompt != "" then $prompt
      else "(no prompt)" end ) as $label

  # Relative age, derived from the file's mtime.
  | (now - $mtime) as $age
  | ( if   $age >= 86400 then "\($age / 86400 | floor)d"
      elif $age >= 3600  then "\($age / 3600  | floor)h"
      elif $age >= 60    then "\($age / 60    | floor)m"
      else "now" end ) as $age_str

  | ( $path | split("/") | last | sub("\\.jsonl$"; "") ) as $session_id
  | ( $cwd  | split("/") | last )                        as $project

  | if $cwd == "" then empty
    else "\($mtime)\t\($session_id)\t\($cwd)\t\(lpad($age_str; 4))  \(rpad($project; 24))  \($label[0:100])"
    end
JQ

# Build a row per session (reading only the first 200 KB of each -- cwd, title
# and first prompt all live near the top), newest first, and pick with fzf.
#
# `cut -f2-` drops the mtime sort key, leaving "<session-id>\t<cwd>\t<display>";
# `--with-nth=3` shows only the pretty display column while the hidden fields
# carry the session id and cwd. fzf draws on /dev/tty, so its UI still works
# when our stdout is captured by the caller.
selection=$(
  for file in "$projects"/*/*.jsonl; do
    [ -e "$file" ] || continue
    head -c 200000 -- "$file" \
      | jq -Rrs --argjson mtime "$(mtime "$file")" --arg path "$file" "$jq_row"
  done \
    | sort -t "$(printf '\t')" -k1,1 -rn \
    | cut -f2- \
    | fzf --ansi --no-sort --delimiter "$(printf '\t')" --with-nth=3 --prompt='resume> '
) || exit 0   # non-zero from fzf means the user cancelled

# selection = "<session-id>\t<cwd>\t<display>"; hand the caller "<cwd>\t<id>".
session_id=$(printf '%s' "$selection" | cut -f1)
cwd=$(printf '%s' "$selection" | cut -f2)
printf '%s\t%s\n' "$cwd" "$session_id"
