#!/usr/bin/env sh
dev=$(hyprctl devices | grep -B7 'main: yes' | grep -A1 'Keyboard at' | tail -1 | sed 's/\s*//')
hyprctl switchxkblayout "$dev" next
