#!/bin/bash
hyprctl --batch $(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
sleep 3
systemctl shutdown
