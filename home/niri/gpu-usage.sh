#!/usr/bin/env bash
set -euo pipefail

GPU=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1)
MEM=$(cat /sys/class/drm/card*/device/mem_info_vram_used 2>/dev/null | head -1)
[[ -z "$GPU" ]] && exit 0
MEM_MB=$(( MEM / 1024 / 1024 ))
printf '{"text":"%s%%","tooltip":"GPU %s%% VRAM %s MiB","percentage":%s}\n' \
  "$GPU" "$GPU" "$MEM_MB" "$GPU"
