{ inputs, outputs, lib, config, pkgs, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    # CLI apps
    btop
    curl
    fishPlugins.colored-man-pages # self-descriptive
    fishPlugins.done # get notification when long process finishes
    fzf
    gh
    git
    killall
    nitch
    nerdfix # removes obsolete nerd font icons
    unzip
    starship
    wget

    # GUI apps
    discord
    firefox-bin
    google-chrome
    keepassxc
    kitty
    nur.repos.nltch.spotify-adblock
    viber

    # Javascript
    nodejs
    typescript
    tailwindcss
    nodePackages.npm
    unstable.nodePackages_latest.pnpm
  ];
}
