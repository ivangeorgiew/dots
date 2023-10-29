#!/usr/bin/env bash
hyprctl --batch $(hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "')
sleep 2
