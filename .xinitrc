setxkbmap -layout us,bg -variant ,phonetic -option 'grp:shifts_toggle'
xset r rate 180 30
udiskie &
/usr/bin/start-pulseaudio-x11

dbus-update-activation-environment --systemd DISPLAY
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK

[[ -f ~/.xbindkeysrc ]] && xbindkeys
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

exec i3
