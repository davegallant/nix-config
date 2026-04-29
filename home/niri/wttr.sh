#!/usr/bin/env bash
set -euo pipefail

for i in 1 2 3 4 5; do
  result=$(curl -s --max-time 5 "https://wttr.in/__WEATHER_COORDS__?format=%c+%t")
  [ -n "$result" ] && echo "$result" | tr -s ' ' && exit 0
  sleep 3
done
echo "no network"
