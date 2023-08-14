{ pkgs, ... }:
{
  environment.systemPackages = with pkgs;
  [
    # Dev tools
    vim
    wget
    curl
    git
    unzip
    gh

    # GUI apps
    keepassxc
    google-chrome
    #kitty
    #arandr

    # Just use the (browser app + ublock) instead
    #spotify
    #nur.repos.instantos.spotify-adblock

    # DE/WM apps
    #bspwm
    #sxhkd
    #nitrogen
    #polybar
    #rofi
    #pavucontrol
    #killall
    #lxappearance
    #dunst
    #udiskie
  ];
}
