#!/bin/sh
# Codex `notify` program: desktop notification (OSC 777) on agent-turn-complete.
# tui.notification_method = "bel" takes the TUI's one notification slot for the
# bell, so this restores the desktop notification alongside it. Codex passes the
# event JSON as the last argument. Write to the tty of the nearest ancestor that
# has one (Codex itself), since this process may have no controlling terminal.
event="${1:-}"
[ "$(printf '%s' "$event" | jq -r '.type // empty' 2>/dev/null)" = agent-turn-complete ] || exit 0

# Strip control characters and ";" (the OSC 777 field separator), then truncate.
body=$(printf '%s' "$event" | jq -r '."last-assistant-message" // ""' 2>/dev/null |
  tr -d '\000-\037\177' | tr ';' ',' | cut -c1-200)
[ -n "$body" ] || body="Ready for input"

pid=$PPID
while [ "${pid:-1}" -gt 1 ]; do
  tty=$(ps -o tty= -p "$pid" | tr -d ' ')
  case "$tty" in
    "" | "?" | "??") ;;
    *)
      printf '\033]777;notify;Codex;%s\a' "$body" >"/dev/$tty" 2>/dev/null
      exit 0
      ;;
  esac
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
done
exit 0
