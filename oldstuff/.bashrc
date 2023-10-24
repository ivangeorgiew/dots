#!/bin/bash

#Set up the prompt
BLUE="\[\033[38;5;39m\]"
GREEN="\[\033[38;5;76m\]"
RESET="\[$(tput sgr0)\]"
export PS1="${BLUE}\u${RESET}[${GREEN}\w${RESET}]\n\\$ ${RESET}"

#Aliases
alias l="ls -l"
alias ll="ls -la"
alias kl="pkill -9" # Force kill a process (hence the 9)
alias ks="ps aux | grep" # List a process
alias nix-up="sudo nixos-rebuild switch --flake ~/dotfiles/nix/#" # Change nixos config now
alias nix-bt="sudo nixos-rebuild boot --flake ~/dotfiles/nix/#" # Change nixos config after boot
alias p="pnpm"

# Disable the default Ctrl-s and Ctrl-q behaviour
stty -ixon

#Environment variables
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_BIN_HOME="${HOME}/.local/bin"
export XDG_LIB_HOME="${HOME}/.local/lib"
export PATH="${PATH}:${XDG_BIN_HOME}"
#export HISTFILE="/etc/bash/.${USER}_history" #Bash history file
export HISTCONTROL="ignoreboth:erasedups"
export LESSHISTFILE="-" #No history file for less
#export INPUTRC="${XDG_CONFIG_HOME}/.inputrc" #Readline settings (which bash uses)
#export GTK2_RC_FILES="${XDG_CONFIG_HOME}/gtk-2.0/gtkrc-2.0"
#export QT_QPA_PLATFORMTHEME="gtk2" #Have QT use gtk2 theme
#export MOZ_USE_XINPUT2="1" #Firefox smooth scrolling/touchpads
#export _JAVA_AWT_WM_NONREPARENTING=1 #Fix for Japa applications in dwm
export EDITOR="vim"
export TERMINAL="kitty"
export BROWSER="google-chrome-stable"
#export READER="zathura"
