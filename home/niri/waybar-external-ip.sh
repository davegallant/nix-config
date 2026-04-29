#!/usr/bin/env bash
set -euo pipefail

data=$(curl -s https://ipinfo.io/json)
ip=$(echo "$data" | jq -r '.ip')
country=$(echo "$data" | jq -r '.country | ascii_upcase')
if [[ "$country" =~ ^[A-Z]{2}$ ]]; then
  c1=$(printf '%d' "'${country:0:1}")
  c2=$(printf '%d' "'${country:1:1}")
  f1=$(printf '\U%08x' $((0x1F1E6 + c1 - 65)))
  f2=$(printf '\U%08x' $((0x1F1E6 + c2 - 65)))
  flag="$f1$f2"
else
  flag="🌐"
fi
printf '{"text":"%s","tooltip":"%s"}\n' "$flag" "$ip"
