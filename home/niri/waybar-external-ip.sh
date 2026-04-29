#!/usr/bin/env bash
set -euo pipefail

data=$(curl -s https://ipinfo.io/json)
ip=$(echo "$data" | jq -r '.ip')
country=$(echo "$data" | jq -r '.country')
c1=$(printf '%d' "'$(echo "$country" | cut -c1)")
c2=$(printf '%d' "'$(echo "$country" | cut -c2)")
f1=$(printf '\U'$(printf '%08x' $((0x1F1E6 + c1 - 65))))
f2=$(printf '\U'$(printf '%08x' $((0x1F1E6 + c2 - 65))))
printf '{"text":"%s","tooltip":"%s"}\n' "$f1$f2" "$ip"
