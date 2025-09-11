#!/usr/bin/env bash
hyprctl -j clients | jq -j '.[] | "dispatch closewindow address:\(.address); "' | xargs -r hyprctl --batch
sleep 2
