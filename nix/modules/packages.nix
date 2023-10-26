{ inputs, outputs, lib, config, pkgs, ... }:
{
  # Add packages
  environment.systemPackages = with pkgs; [
    # CLI apps
    btop # system monitor
    curl
    cava # audio visualizer
    fishPlugins.colored-man-pages
    fishPlugins.done # get notification when long process finishes
    fzf # fuzzy file searcher
    gh # github authenticator
    git
    killall
    nitch # alternative to neofetch
    nerdfix # removes obsolete nerd font icons
    unzip
    stow # symlink dotfiles
    (python310.withPackages(ps: with ps; [ requests pygobject3 ]))
    gobject-introspection # for some python scripts
    wget

    # GUI apps
    discord
    unstable.firefox-bin
    unstable.google-chrome
    unstable.brave
    keepassxc
    kitty
    nur.repos.nltch.spotify-adblock
    viber

    # Javascript
    nodejs
    typescript
    nodePackages.npm
    unstable.nodePackages_latest.pnpm
    unstable.nodePackages_latest.tailwindcss
  ];

  # Config/add packages
  programs = {
    # Interactive shell
    fish = {
      enable = true;

      useBabelfish = true; # Bash to Fish translation

      interactiveShellInit = ''
        #Disable greeting
        set fish_greeting

        # Display system info
        nitch
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
    
    # prompt
    starship.enable = true;

    # IDE/Text editor
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
