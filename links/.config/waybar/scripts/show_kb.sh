#!/usr/bin/env sh

while true; do
  layout=$(hyprctl devices | grep -B7 'main: yes' | grep -A4 'Keyboard at' | tail -1 | sed 's/.*: //;s/ .*//' | cut -c 1-3 | tr '[A-Z]' '[a-z]')
  echo "$layout"
  sleep 0.2
done
