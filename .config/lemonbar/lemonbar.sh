#!/usr/bin/env bash
# lemonbar-xft-git is required for for fontconfig typefaces

# hex colours
green='#00EE00'
grey='#888888'
red='#FF0000'
yellow='#FFFF00'

Battery() {
  capacity=$(grep -hs ^ /sys/class/power_supply/BAT0/capacity)
  if [ -n "$capacity" ]; then
    case $capacity in
    [0-9]) colour=$red ;;
    [0-1][0-9]) colour=$red ;;
    [2-3][0-9]) colour=$yellow ;;
    *) colour=$green ;;
    esac
    echo -e " %{F$colour}[$capacity%]%{F-}%{B-}"
  fi
}

Clock() {
  TIME=$(date '+%l:%M:%S %p')
  echo -e -n " ${TIME}"
}

Calendar() {
  DATE=$(date "+%a, %D")
  echo -e -n " ${DATE}"
}

ActiveWindow() {
  len=$(echo -n "$(xdotool getwindowfocus getwindowname)" | wc -m)
  max_len=70
  if [ "$len" -gt $max_len ]; then
    title="$(xdotool getwindowfocus getwindowname | cut -c 1-$max_len)..."
  else
    title="$(xdotool getwindowfocus getwindowname)"
  fi
  echo -n " %{F$grey}[ $title ]%{F-}%{B-}"
}

Ip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}

while true; do
  desktop_name=$(bspc query -D -d focused --names)
  panel_info=$(echo -e "%{c}[$desktop_name] $(ActiveWindow)" "%{r}$ip $(Calendar)$(Clock)$(Battery)")
  # List of all the monitors/screens
  monitors=$(xrandr | grep -o "^.* connected" | sed "s/ connected//")
  tmp=0
  barout=''
  for _ in echo "$monitors"; do
    barout+="%{S${tmp}}$panel_info"
    ((tmp = tmp + 1))
  done
  echo "$barout"
  sleep 0.1s
done
