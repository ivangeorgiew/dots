setxkbmap -layout us,bg -variant ,phonetic -option 'grp:shifts_toggle'
xset r rate 170 50
xset s off
xset -dpms
udiskie &
/usr/bin/start-pulseaudio-x11

dbus-update-activation-environment --systemd DISPLAY
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

[[ -f ~/.xbindkeysrc ]] && xbindkeys
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
xrandr --output DP-0 --mode 3840x2160 --dpi 192
xinput --set-prop 11 'libinput Accel Speed' -0.7

exec i3
