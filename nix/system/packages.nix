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

  programs = {
    fish = {
      enable = true;
      
      # Fix for/from https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
      loginShellInit =
        let
          dquote = str: "\"" + str + "\"";
          makeBinPathList = map (path: path + "/bin");
        in ''
          fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
          set fish_user_paths $fish_user_paths
        '';

      # Bash to Fish translation
      useBabelfish = true;
    };
    
    
  };
}
