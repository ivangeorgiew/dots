#!/usr/bin/env dash

while true; do
  if pgrep spotify >/dev/null; then
    playerctl -p spotify play 2>/dev/null

    status="$(playerctl -p spotify status 2>/dev/null)"

    if [ "$status" = "Playing" ]; then
      break
    fi
  fi
done
