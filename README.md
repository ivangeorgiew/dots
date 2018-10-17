# dotfiles
My dotfiles, some of which are borrowed from https://github.com/mscoutermarsh/dotfiles.

You have to do these things in order:

If you use ArchLinux:
1) Install Antergos base
2) Identify your video card and install the corresponding drivers: `lspci | grep -e VGA -e 3D`
3) CHOOSE ONE: `pacman -S nvidia` OR `pacman -S xf86-video-ati` OR `pacman -S xf86-video-intel`
4) Change the username in settings/autologin@.service file
5) `~/dotfiles/archScript`
6) `~/dotfiles/install`
7) Change your keyboard layout in .xinitrc
8) `~/dotfiles/fonts/install.sh`
9) `startx`
10) `sudo reboot`
11) `mkdir ~/.npm-global`
12) `npm config set prefix '~/.npm-global'`
13) `npm i -g npm@5.8.0 node@8.11.2`
14) `source ~/.zshrc`
15) `npm i -g import-js`
16) `rm -fr ~/.npm-global/lib/node_modules/import-js/lib`
17) `cd ~/` and `git clone https://github.com/ivangeorgiew/import-js.git`
18) `cp -R lib ~/.npm-global/lib/node_modules/import-js/lib`
19) `cd ~/.npm-global/lib/node_modules/import-js` and `npm i` and `npm run build`
20) Find your active network interface: `ifconfig -a`
21) Update the wlan/eth modules in ~/.config/polybar/config
22) `pacmd list-sinks` and change the index in ~/.config/i3/config pactl shortcuts
23) `cd ~/dotfiles/.vim/bundle && git submodule update --init --recursive`
24) Follow the YouCompleteMe instructions: https://github.com/Valloric/YouCompleteMe (install with `path/to/python ./install.py`)
25) `xdg-settings set default-web-browser google-chrome.desktop`
26) `ln -s /run/media/YOUR_NAME ~/media`
27) Install `icaclient` and copy `All_Regions.ini` to `~/.ICAClient/All_Regions.ini`
28) Increase number of watchers: `echo fs.inotify.max_user_watches=524288 | sudo tee /etc/sysctl.d/40-max-user-watches.conf && sudo sysctl --system`

If you use MacOS:
1) Install iTerm
2) Install https://github.com/Lokaltog/powerline-fonts. I use cousine for powerline
3) Install tmux
4) Install Xcode full version
5) Install macvim --with-override-system-vim
6) Install Node.js
7) Install zsh
8) Install oh-my-zsh
9) Install Exuberant Ctags with brew
10) Install import-js globally
11) `git clone https://github.com/ivangeorgiew/dotfiles.git ~/dotfiles`
12) `cd ~/dotfiles`
13) If you want to remove any of the plugins in vim/bundle DO IT NOW
14) `git submodule update --init --recursive`
15) `./install`
16) Follow the YouCompleteMe build instructions: https://github.com/Valloric/YouCompleteMe#full-installation-guide
