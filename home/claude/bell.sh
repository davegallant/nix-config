#!/bin/sh
# Ring the terminal bell from a Claude Code hook, so Ghostty flags the tab
# (bell-features). Hooks have no controlling terminal and /dev/tty fails, so
# write to the tty of the nearest ancestor that has one: Claude itself.
pid=$PPID
while [ "${pid:-1}" -gt 1 ]; do
  tty=$(ps -o tty= -p "$pid" | tr -d ' ')
  case "$tty" in
    "" | "?" | "??") ;;
    *)
      printf '\a' >"/dev/$tty" 2>/dev/null
      exit 0
      ;;
  esac
  pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
done
exit 0
