#!/usr/bin/env dash

dir="$1"
window_pid=$(hyprctl activewindow | rg 'pid: ' | sed 's/.*: //;')
process_pids=$(pstree -p $window_pid | sed 's/^[^0-9]*//g;s/ .*/ /g' | tr '\n' ' ')

# loop through all the child processes
for pp in $process_pids; do
  pn="$(cat /proc/$pp/comm 2>/dev/null)"

  if [ "$pn" = "nvim" ]; then
    proc_pid="$pp"
    proc_name="$pn"
  fi
done

if [ "$proc_name" != "nvim" ]; then
  hyprctl dispatch movefocus "$dir"
else
  nvim --server "/run/user/1000/nvim.$proc_pid.0" --remote-send ":Navigate $dir<cr>" &>/dev/null
fi
