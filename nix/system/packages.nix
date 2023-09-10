{ config, pkgs, lib, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    # Dev tools
    vim
    wget
    curl
    git
    gh
    unzip
    killall
    btop
    fzf
    fishPlugins.colored-man-pages # self-descriptive
    fishPlugins.done # get notification when long process finishes

    # GUI apps
    keepassxc
    google-chrome
    firefox-bin
    discord
    kitty
    viber
    nur.repos.nltch.spotify-adblock

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

  # Package Configs
  programs = {
    # Interactive shell
    fish = {
      enable = true;

      useBabelfish = true; # Bash to Fish translation

      interactiveShellInit = ''
        #Disable greeting
        set fish_greeting
      '';

      loginShellInit =
      let
        dquote = str: "\"" + str + "\"";
        makeBinPathList = map (path: path + "/bin");
      in ''
        # Fix for/from https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
        set fish_user_paths $fish_user_paths
      '';
    };

    # Shell prompt
    starship = {
      enable = true;      
      #settings = {};
      #interactiveOnly = false;
    };
  };
}
