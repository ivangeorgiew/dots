{ inputs, outputs, lib, config, pkgs, ... }:
{
  # Add packages
  environment.systemPackages = with pkgs; [
    # CLI apps and tools
    btop # system monitor
    cava # audio visualizer
    cmatrix # cool effect
    curl
    fd # better alternative to find
    fishPlugins.colored-man-pages
    fishPlugins.done # get notification when long process finishes
    fzf # fuzzy file searcher
    gcc # c compiler
    gh # github authenticator
    git
    glibc
    gnumake # make command
    jq # json processor
    killall
    ffmpeg # for audio and video
    pavucontrol # audio control
    lazygit # terminal UI for git commands
    nerdfix # removes obsolete nerd font icons
    nitch # alternative to neofetch
    p7zip # archiving and compression
    pulseaudio # for pactl only
    ripgrep # newest silver searcher + grep
    shared-mime-info # add new custom mime types (check arch wiki)
    stow # symlink dotfiles
    tree-sitter # needed by neovim
    libvterm-neovim # needed by neovim
    wget

    # GUI apps
    vesktop # discord + additions
    firefox-bin # browser
    google-chrome # browser
    brave # browser
    keepassxc # password manager
    kitty # terminal
    nur.repos.nltch.spotify-adblock # spotify
    viber # chat app
    qbittorrent # torrent downloading
    libsForQt5.ark # 7-zip alternative
    celluloid # mpv with GUI (video player)
    mpv # video player

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
