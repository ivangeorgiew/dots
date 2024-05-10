#!/usr/bin/env dash

AW=$(hyprctl monitors | rg "active workspace: " | cut -d " " -f3)
(( $AW > 2 )) && AW=2
hyprctl dispatch workspace "$((3-$AW))"
