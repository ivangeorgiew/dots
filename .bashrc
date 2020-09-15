#!/bin/bash

#Set up the prompt
BLUE="\[\033[38;5;39m\]"
GREEN="\[\033[38;5;76m\]"
RESET="\[$(tput sgr0)\]"
export PS1="${BLUE}\u${RESET}[${GREEN}\w${RESET}]\n\\$ ${RESET}"

#Aliases for xbps from void
#alias xu="sudo xbps-install -Su" #Update void
#alias xi="sudo xbps-install -S" #Install package
#alias xr="sudo xbps-remove -R" #Remove package and dependencies
#alias xo="sudo xbps-remove -Oo" #Remove orphan packages
#alias xs="sudo xbps-query -Rs" #Search package repository
#alias xS="sudo xbps-query -s" #Search from installed packages
#alias xl="sudo xbps-query -m" #List explicitly installed packages
alias l="ls -l"
alias ll="ls -la"
alias kl="pkill -9" #Force kill a process (hence the 9)
alias ks="ps aux | grep"

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
#export EDITOR="nvim"
#export TERMINAL="st"
#export BROWSER="firefox"
#export READER="zathura"

# launch ssh-agent for git automatically
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start &> /dev/null
    ssh-add &> /dev/null
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add &> /dev/null
fi

unset env

alias pnp="pnpm"

cd ~/projects

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/bash/__tabtab.bash ] && . ~/.config/tabtab/bash/__tabtab.bash || true

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
