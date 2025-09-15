#!/usr/bin/env dash

arg="$1"
dir="$HOME/Videos"
file="$dir/rec_$(date '+%y-%m-%d_%H-%M-%S').mkv"
time="10m"

[ -d "$dir" ] || mkdir -p "$dir"

case "$arg" in
  whole)
    notify-send "Screen Recording" "Started a whole screen recording"
    timeout -s SIGINT "$time" wf-recorder -f "$file"
    ;;
  partial)
    notify-send "Screen Recording" "Started a partial screen recording"
    timeout -s SIGINT "$time" wf-recorder -f "$file" -g "$(slurp)"
    ;;
  stop)
    notify-send "Screen Recording" "Stopped screen recording"
    killall -s SIGINT wf-recorder
    ;;
esac
