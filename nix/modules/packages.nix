{ inputs, outputs, lib, config, pkgs, ... }:
{
  # Add packages
  environment.systemPackages = with pkgs; [
    # CLI apps and tools
    btop # system monitor
    cava # audio visualizer
    cmatrix # cool effect
    curl # download files
    fd # better alternative to find
    ffmpeg # for audio and video
    fishPlugins.colored-man-pages
    fishPlugins.done # get notification when long process finishes
    fswatch # file change monitor required by some programs
    fzf # fuzzy file searcher
    gcc # c compiler
    gh # github authenticator
    git # obvious
    glibc # need by some programs
    gnumake # make command
    jq # json processor
    killall # kill a running process
    lazygit # terminal UI for git commands
    libvterm-neovim # needed by neovim
    nerdfix # removes obsolete nerd font icons
    nitch # alternative to neofetch
    p7zip # archiving and compression
    pavucontrol # audio control
    ripgrep # newest silver searcher + grep
    shared-mime-info # add new custom mime types (check arch wiki)
    stow # symlink dotfiles
    tree-sitter # needed by neovim
    unzip # required by some programs
    wget # download files

    # GUI apps
    brave # browser
    celluloid # mpv with GUI (video player)
    firefox-bin # browser
    floorp # browser
    gedit # basic text editor GUI
    google-chrome # browser
    keepassxc # password manager
    kitty # terminal
    libsForQt5.ark # 7-zip alternative
    mpv # video player
    nur.repos.nltch.spotify-adblock # spotify
    qbittorrent # torrent downloading
    vesktop # discord + additions
    viber # chat app

    #Lua
    lua

    # Python
    (python310.withPackages(ps: with ps; [ requests pygobject3 ]))
    gobject-introspection # for some python scripts

    # Javascript
    nodejs
    nodePackages.npm
    nodePackages_latest.pnpm
    nodePackages_latest.tailwindcss
    nodePackages_latest.typescript
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

        # Start in the projects folder
        if not test -d projects
          mkdir projects
        end

        cd projects
      '';

      #loginShellInit =
      #let
      #  dquote = str: "\"" + str + "\"";
      #  makeBinPathList = map (path: path + "/bin");
      #in ''
      #  # Fix for/from https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
      #  fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
      #  set fish_user_paths $fish_user_paths
      #'';
    };

    # shell prompt
    starship.enable = true;

    # IDE/Text editor
    neovim = {
      enable = true;
      package = pkgs.neovim; # overlayed neovim-nightly
      withRuby = true;
      withPython3 = true;
      withNodeJs = true;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
