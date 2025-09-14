#!/usr/bin/env dash
hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "' | xargs -r hyprctl --batch
sleep 3
