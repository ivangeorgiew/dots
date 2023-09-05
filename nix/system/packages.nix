{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Dev tools
    vim
    wget
    curl
    git
    unzip
    gh
    killall
    htop
    gh

    # GUI apps
    keepassxc
    google-chrome
    discord
    kitty
    viber

    # Spotify. Browser app + ublock can be used instead
    #spotify
    #nur.repos.instantos.spotify-adblock

    # DE/WM apps
    #bspwm
    #sxhkd
    #nitrogen
    #polybar
    #rofi
    #pavucontrol
    #lxappearance
    #dunst
    #udiskie
  ];
}
