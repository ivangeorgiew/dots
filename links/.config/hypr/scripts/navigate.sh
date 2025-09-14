#!/usr/bin/env dash

v_dir="$1"
window_pid=$(hyprctl activewindow | rg 'pid: ' | sed 's/.*: //;')
process_pids=$(pstree -p $window_pid | sed 's/^[^1-9]*//g;s/ .*/ /g' | tr '\n' ' ')

# loop through all the child processes
for pp in $process_pids; do
  pn="$(cat /proc/$pp/comm 2>/dev/null)"

  if [ "$pn" = "nvim" ]; then
    proc_pid="$pp"
    proc_name="$pn"
  fi
done

# Map vim dir to hypr dir
case "$v_dir" in
  h)
    h_dir="l"
    ;;
  l)
    h_dir="r"
    ;;
  k)
    h_dir="u"
    ;;
  j)
    h_dir="d"
    ;;
esac

if [ "$proc_name" != "nvim" ]; then
  hyprctl dispatch movefocus "$h_dir"
else
  nvim --server "/run/user/1000/nvim.$proc_pid.0" --remote-send ":Navigate $v_dir<cr>" &>/dev/null
fi
