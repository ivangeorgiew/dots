{pkgs, ...}: {
  # Default shell for all users
  users.defaultUserShell = pkgs.fish;

  environment = {
    # Add ~/.local/bin to PATH
    localBinInPath = true;

    # Add shells to /etc/shells
    shells = with pkgs; [fish];

    systemPackages = with pkgs; [
      # CLI apps
      alejandra # nix code formatter
      babelfish # translate bash scripts to fish
      bat # better alternative to cat
      btop # system monitor
      cava # audio visualizer
      cmatrix # cool effect
      curl # download files
      dash # fastest shell
      fd # better alternative to find
      ffmpeg # for audio and video
      fishPlugins.colored-man-pages
      fishPlugins.done # get notification when long process finishes
      fswatch # file change monitor required by some programs
      fzf # fuzzy file searcher
      gcc # c compiler
      gdu # windirstat for linux (sort dirs by size)
      gh # github authenticator
      gnupg # used to verify downloaded apps
      git # obvious
      glibc # need by some apps
      gnumake # make command
      jq # json processor
      killall # kill a running process
      lazygit # terminal UI for git commands
      lsd # better ls command
      nerdfix # removes obsolete nerd font icons
      nitch # alternative to neofetch
      p7zip # archiving and compression
      pavucontrol # audio control
      pstree # prints tree of pids
      qalculate-qt # calculator
      ripgrep # newest silver searcher + grep
      shared-mime-info # add new custom mime types (check arch wiki)
      stow # symlink dotfiles
      unstable.tree-sitter # used by neovim
      unzip # required by some programs
      wget # download files

      # GUI apps
      anki-bin # SRS (flashcards)
      custom.spotify-no-ads # music player
      unstable.zed-editor # ide/text editor
      easyeffects # sound effects
      gedit # basic text editor GUI
      kdePackages.ark # 7-zip alternative
      kdePackages.kolourpaint # MS Paint for linux
      keepassxc # password manager
      kitty # terminal
      loupe # image viewer
      mpv # video player
      nemo-with-extensions # file manager
      obsidian # note-taking app
      onlyoffice-desktopeditors # MS Office alternative
      qbittorrent # torrent downloading
      unstable.firefox # browser
      unstable.google-chrome # browser
      vesktop # discord + additions
      viber # messaging app
      vlc # video player
      (unstable.vscode.fhsWithPackages (ps: [])) # vscode ide/text editor

      # Programming apps (langs, linters, formatters, etc)
      # Project specific packages should be installed with a devShell + direnv
      (python314.withPackages (ps: with ps; [pip]))
      mise # per-project tool manager
      unstable.opencode # AI coding agent built for the terminal

      # Used by neovim or other IDEs
      neovim-node-client # used by neovim plugins that require node.js
      lua-language-server
      stylua # lua style formatter
      vscode-langservers-extracted # HTML/CSS/JSON/ESLint LSPs extracted from vscode
      prettierd # js formatter daemon
      nil # nix LSP
      vtsls # javascript/typescript LSP
    ];

    sessionVariables = {
      TERMINAL = "kitty";
      BROWSER = "firefox";
      EDITOR = "nvim";
      FILE_MANAGER = "nemo";
      HISTCONTROL = "ignoreboth:erasedups";
      LESSHISTFILE = "-";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_LIB_HOME = "$HOME/.local/lib";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_DESKTOP_DIR = "$HOME/Desktop";
      XDG_DOCUMENTS_DIR = "$HOME/Documents";
      XDG_DOWNLOADS_DIR = "$HOME/Downloads";
      XDG_VIDEOS_DIR = "$HOME/Videos";
      XDG_PICTURES_DIR = "$HOME/Pictures";
    };

    shellAliases = {
      reboot = "systemctl reboot"; # Restart the PC
      shutdown = "systemctl poweroff"; # Shutdown the PC
      ls = "lsd"; # Better ls command
      ll = "lsd -lA1"; # List files and directories
      tree = "lsd --tree"; # Better tree command
      rm = "rm -rI"; # Ask for each file before deleting
      rmdir = "rm -fr"; # Delete dir and files inside it
      mkdir = "mkdir -p"; # Make dirs recursively
      cp = "cp -r"; # Copy recursively
      cat = "bat"; # Show file contents
      find = "fd"; # Find files/folders
      dirs_size = "gdu"; # Windirstat for Linux (sort dirs by size)
      ps_search = "ps aux | rg"; # List a process
      ps_kill = "pkill -9"; # Force kill a process (hence the 9)
      vim = "nvim"; # Redirect to my nvim restarting function
      vi = "nvim"; # Redirect to my nvim restarting function
      neofetch = "nitch"; # Displays system info
      nix_update = "echo '> Updating flake inputs' && sudo nix flake update --flake ~/dots"; # Update the versions of packages
      nix_switch = "nix_update && nh os switch"; # Change nixos config now
      nix_boot = "nix_update && nh os boot"; # Change nixos config after boot
      nix_list = "nh os info"; # List nixos generations
      nix_roll = "nh os rollback --to"; # Rollback to a generation
      nix_search = "nh search"; # Search nix packages
      nix_gc = "nh clean all --ask --optimise --keep 3 --keep-since 15d"; # Garbage collect nixos
      nix_gc_all = "nh clean all --ask --optimise"; # Garbage collect all but 1 nixos generation
      nix_fmt = "nix fmt -- ~/dots/**/*.nix"; # Format all the nix files in my repo
      nix_create_shell = "nix flake init -t ~/dots"; # Create nix devshell
    };
  };

  # Config/add packages
  programs = {
    # Interactive shell
    fish = {
      enable = true;

      useBabelfish = true; # Bash to Fish translation

      interactiveShellInit = ''
        function multicd
          set -l length (math (string length -- $argv) - 1)
          echo cd (string repeat -n $length ../)
        end

        abbr --add dotdot --regex '^\.\.+$' --function multicd

        function go_to_project
          # list of project dirs
          set -l dirs $(fd . --exact-depth 1 -t d -L ~/projects ~/.config)

          # append to `dirs`
          set -a dirs ~/dots
          set -a dirs ~/projects

          # wanted project path
          set -l dir_path (string split ' ' $dirs | fzf)

          # cd only if valid directory was selected
          if test -d "$dir_path"
            cd $dir_path
          end
        end

        bind \cg 'go_to_project; commandline -f repaint'

        # Create ~/projects folder if needed
        if test ! -d "~/projects"
          mkdir ~/projects
        end

        # Setup mise tool manager
        if command -q mise
          mise activate fish | source
        end

        # Disable greeting
        set fish_greeting

        # Display system info
        # nitch
      '';
    };

    # Shell prompt
    starship = {
      enable = true;
      # package = pkgs.starship;
    };

    # IDE/Text editor
    neovim = {
      enable = true;

      package = pkgs.unstable.neovim-unwrapped;
      # package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

      viAlias = true;
      vimAlias = true;

      withRuby = true;
      withPython3 = true;
      withNodeJs = true;
    };

    java = {
      enable = true;
      # binfmt = true;
      # package = pkgs.jdk; # can be substituted to oracle version
    };

    # Combined with flake shell, autoloads packages and env variables when entering directories
    direnv = {
      enable = true;
      silent = true; # toggles direnv logging
      loadInNixShell = true; # load direnv in `nix develop`
      # package = pkgs.direnv;
      # direnvrcExtra = ''; # extra config

      # Shell integration is enabled by default

      nix-direnv = {
        enable = true; # better implementation
        # package = pkgs.nix-direnv;
      };
    };

    dconf = {
      enable = true;

      profiles.user.databases = [
        {
          settings = {
            "org/nemo/preferences" = {
              click-policy = "double";
              date-format = "iso";
              show-advanced-permissions = true;
              show-hidden-files = true;
              show-toggle-extra-pane-toolbar = true;
              size-prefixes = "base-10";
              tooltips-in-icon-view = false;
              tooltips-in-list-view = false;
            };
            "org/nemo/preferences/menu-config" = {
              selection-menu-open-as-root = false;
              selection-menu-open-in-new-tab = false;
              selection-menu-pin = false;
            };
          };
        }
      ];
    };
  };

  # Associate programs with file extensions
  xdg.mime =
    # List from /run/current-system/sw/share/applications
    let
      browser = "firefox.desktop";
      torrent = "org.qbittorrent.qBittorrent.desktop";
      imgviewer = "org.gnome.Loupe.desktop";
      file_manager = "nemo.desktop";
    in {
      defaultApplications = {
        "text/html" = "${browser}";
        "x-scheme-handler/http" = "${browser}";
        "x-scheme-handler/https" = "${browser}";
        "x-scheme-handler/about" = "${browser}";
        "x-scheme-handler/unknown" = "${browser}";

        "x-scheme-handler/magnet" = "${torrent}";
        "application/x-bittorrent" = "${torrent}";

        "image/jpeg" = "${imgviewer}";
        "image/png" = "${imgviewer}";
        "image/gif" = "${imgviewer}";
        "image/bmp" = "${imgviewer}";
        "image/svg+xml" = "${imgviewer}";
        "image/tiff" = "${imgviewer}";

        "inode/directory" = "${file_manager}";
        "application/x-gnome-saved-search" = "${file_manager}";
      };
    };
}
