#!/usr/bin/env bash
# Cross-repo GitHub PR status: what needs my review, what I have open, and the
# team review queue. `gh pr list`/`gh pr status` are repo-scoped, so everything
# here goes through `gh search prs`.
#
# On a terminal each PR ref is an OSC 8 hyperlink; piped output is markdown so it
# pastes cleanly elsewhere.
set -euo pipefail

team_limit=10
style=auto

while [ $# -gt 0 ]; do
  case $1 in
  -a | --all) team_limit=0 ;;
  -m | --markdown) style=markdown ;;
  -l | --links) style=term ;;
  *)
    echo "usage: ${0##*/} [-a|--all] [-m|--markdown] [-l|--links]" >&2
    exit 2
    ;;
  esac
  shift
done

if [ "$style" = auto ]; then
  if [ -t 1 ]; then style=term; else style=markdown; fi
fi

esc=$'\033'
if [ "$style" = term ]; then
  bold="${esc}[1m" dim="${esc}[2m" cyan="${esc}[36m" yellow="${esc}[33m" reset="${esc}[0m"
  link_open="${esc}]8;;" link_mid="${esc}\\" link_close="${esc}]8;;${esc}\\"
else
  bold="" dim="" cyan="" yellow="" reset=""
  link_open="" link_mid="" link_close=""
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# --archived=false drops PRs in archived repos: still open, never actionable.
# --limit defaults to 30 and truncates silently, hence the explicit 1000.
# Each query emits `ref US url US note US title` for `render` to style below. The
# separator is US (0x1f), not a tab: tab is an IFS whitespace char, so `read`
# would collapse the empty note field and shift the title into it.

# user-review-requested: is direct-asks-only and has no flag, so it must be a
# single positional query string with everything else passed as flags.
gh search prs "user-review-requested:@me" --archived=false --state=open --limit 1000 \
  --json repository,number,title,author,url,updatedAt \
  --jq 'sort_by(.updatedAt)|reverse|.[]|["\(.repository.nameWithOwner)#\(.number)",.url,"@\(.author.login)",.title]|join("\u001f")' \
  >"$tmp/mine-to-review" &

gh search prs --author=@me --archived=false --state=open --limit 1000 \
  --json repository,number,title,isDraft,url,updatedAt \
  --jq 'sort_by(.updatedAt)|reverse|.[]|["\(.repository.nameWithOwner)#\(.number)",.url,(if .isDraft then "draft" else "" end),.title]|join("\u001f")' \
  >"$tmp/authored" &

# --review-requested is team-inclusive: every PR routed to any team I'm in.
gh search prs --review-requested=@me --archived=false --draft=false --state=open --limit 1000 \
  --json repository,number,title,url,updatedAt \
  --jq 'sort_by(.updatedAt)|reverse|.[]|["\(.repository.nameWithOwner)#\(.number)",.url,"",.title]|join("\u001f")' \
  >"$tmp/team" &

wait

render() {
  local ref url note title
  while IFS=$'\037' read -r ref url note title; do
    if [ "$style" = markdown ]; then
      printf -- '- [%s](%s)%s %s\n' "$ref" "$url" "${note:+ ($note)}" "$title"
    else
      printf -- '  %s%s%s%s%s%s %s\n' \
        "$cyan$bold" "$link_open$url$link_mid" "$ref" "$link_close" "$reset" \
        "${note:+ $yellow($note)$reset}" "$title"
    fi
  done <"$1"
}

heading() {
  if [ "$style" = markdown ]; then
    printf '\n## %s\n\n' "$1"
  else
    printf '\n%s%s%s\n\n' "$bold" "$1" "$reset"
  fi
}

section() {
  heading "$1"
  if [ -s "$2" ]; then
    render "$2"
  else
    printf '%snone%s\n' "$dim" "$reset"
  fi
}

section "Needs my review" "$tmp/mine-to-review"
section "My open PRs" "$tmp/authored"

team_total=$(wc -l <"$tmp/team" | tr -d ' ')
if [ "$team_limit" -gt 0 ] && [ "$team_total" -gt "$team_limit" ]; then
  heading "Team review queue ($team_total total, $team_limit most recent)"
  head -n "$team_limit" "$tmp/team" >"$tmp/team-head"
  render "$tmp/team-head"
  printf '\n%sRun with --all for the remaining %s.%s\n' "$dim" "$((team_total - team_limit))" "$reset"
else
  section "Team review queue ($team_total total)" "$tmp/team"
fi
