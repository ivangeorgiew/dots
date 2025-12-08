{
  inputs,
  lib,
  config,
  pkgs,
  username,
  ...
}: let
  iconTheme = "Papirus-Dark";
  themeName = "adw-gtk3-dark";
  fontName = "Noto Sans Medium 11";
  cursorTheme = "Bibata-Modern-Classic";
  cursorSize = "24";
in {
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
      custom.lua_ls # lua-language-server
      dash # fastest shell
      devbox # version manager (npm, pnpm, go, python, etc)
      fd # better alternative to find
      ffmpeg # for audio and video
      fishPlugins.colored-man-pages
      fishPlugins.done # get notification when long process finishes
      fswatch # file change monitor required by some programs
      fzf # fuzzy file searcher
      gcc # c compiler
      gdu # windirstat for linux (sort dirs by size)
      gh # github authenticator
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
      qalculate-gtk # calculator
      ripgrep # newest silver searcher + grep
      shared-mime-info # add new custom mime types (check arch wiki)
      stow # symlink dotfiles
      tree-sitter # used by neovim
      unzip # required by some programs
      wget # download files

      # GUI apps
      custom.spotify-no-ads # music player
      custom.vesktop # discord + additions
      custom.viber # messaging app
      easyeffects # sound effects
      gedit # basic text editor GUI
      kdePackages.ark # 7-zip alternative
      kdePackages.kolourpaint # MS Paint for linux
      keepassxc # password manager
      kitty # terminal
      loupe # image viewer
      mpv # video player
      nautilus # file manager
      onlyoffice-desktopeditors # MS Office alternative
      qbittorrent # torrent downloading
      unstable.firefox-bin # browser
      unstable.google-chrome # browser
      unstable.obsidian # note-taking app
      vlc # video player

      # Programming apps
      (python312.withPackages (ps: with ps; [pip]))
      go
      lua51Packages.lua
      luarocks
      nodejs
      ruby
      julia
      cargo
      php
      php83Packages.composer

      # Theme apps
      adw-gtk3 # used for GTK theming
      bibata-cursors # cursors
      dconf-editor # check dconf settings (GTK)
      papirus-icon-theme # icons for GTK
    ];

    sessionVariables = {
      TERMINAL = "kitty";
      BROWSER = "firefox";
      FILE_MANAGER = "nautilus";
      HISTCONTROL = "ignoreboth:erasedups";
      LESSHISTFILE = "-";
      GTK_THEME = themeName;
      XCURSOR_THEME = cursorTheme;
      XCURSOR_SIZE = cursorSize;
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
      vim = "v"; # Redirect to my nvim restarting function
      vi = "v"; # Redirect to my nvim restarting function
      lazyvim = "NVIM_APPNAME=lazyvim v"; # use the LazyVim neovim config
      nvchad = "NVIM_APPNAME=nvchad v"; # use the NvChad neovim config
      neofetch = "nitch"; # Displays system info
      nix_update = "echo '> Updating flake inputs' && sudo nix flake update --flake ~/dots"; # Update the versions of packages
      nix_switch = "nix_update && nh os switch"; # Change nixos config now
      nix_boot = "nix_update && nh os boot"; # Change nixos config after boot
      nix_list = "nh os info"; # List nixos generations
      nix_roll = "nh os rollback --to"; # Rollback to a generation
      nix_gc = "nh clean all --ask --keep 3 --keep-since 5d"; # Garbage collect nixos
      nix_gc_all = "nh clean all --ask"; # Garbage collect all but 1 nixos generation
      nix_fmt = "nix fmt -- ~/dots/**/*.nix"; # Format all the nix files in my repo
    };

    etc = {
      # GTK theming - just in case of old/broken apps
      "gtk-2.0/gtkrc".text = ''
        gtk-icon-theme-name = "${iconTheme}"
        gtk-theme-name = "${themeName}"
        gtk-font-name = "${fontName}"
        gtk-cursor-theme-name="${cursorTheme}"
        gtk-cursor-theme-size=${cursorSize}
      '';
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-icon-theme-name=${iconTheme}
        gtk-theme-name=${themeName}
        gtk-font-name = ${fontName}
        gtk-cursor-theme-name=${cursorTheme}
        gtk-cursor-theme-size=${cursorSize}
      '';
      "gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-icon-theme-name=${iconTheme}
        gtk-theme-name=${themeName}
        gtk-font-name = ${fontName}
        gtk-cursor-theme-name=${cursorTheme}
        gtk-cursor-theme-size=${cursorSize}
      '';
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

        function update_nix_inputs
          if count $argv > /dev/null
            set -l a (string join " " $argv)
            eval "sudo nix flake update $a --flake ~/dots"
          end
        end

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

        # function which restarts neovim on `:cq`
        function v
          nvim $argv

          # restart only on :cq which exits with 1
          while test $status -eq 1
            NVIM_RELOADED=1 nvim
          end
        end

        # Create ~/projects folder if needed
        if test ! -d "~/projects"
          mkdir ~/projects
        end

        # Disable greeting
        set fish_greeting

        # Display system info
        # nitch

        # Hook direnv
        direnv hook fish | source

        # add the npm globals to PATH
        # manually do `npm i` inside the directory when you want to update
        fish_add_path --path ~/.npm-global/node_modules/.bin

        # Install npm global packages if needed
        set -l npm_dir ~/.npm-global

        if command -q npm && test -d "$npm_dir" && test ! -d "$npm_dir/node_modules"
          cd $npm_dir

          # install npm global packages
          echo "Installing global npm packages..."
          npm i

          cd -
        end
      '';
    };

    # Shell prompt
    starship.enable = true;

    # IDE/Text editor
    neovim = {
      enable = true;

      # Don't use neovim-nightly (0.12) for now, cuz of issues
      package = pkgs.unstable.neovim-unwrapped;

      defaultEditor = true;
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

    # Combined with devbox or a flake shell, autoloads
    # packages and env variables when entering directories
    direnv = {
      enable = true;
      silent = true; # toggles direnv logging
      loadInNixShell = true; # load direnv in `nix develop`
      # package = pkgs.direnv;
      # direnvrcExtra = ''; # extra config

      nix-direnv = {
        enable = true; # better implementation
        # package = pkgs.nix-direnv;
      };
    };

    # GTK theming - newer apps
    dconf = {
      enable = true;

      # check different values with dconf-editor
      # example config: https://github.com/Electrostasy/dots/blob/c62895040a8474bba8c4d48828665cfc1791c711/profiles/system/gnome/default.nix#L123-L287
      profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            gtk-theme = themeName;
            icon-theme = iconTheme;
            font-name = fontName;
            document-font-name = fontName;
            monospace-font-name = fontName;
            cursor-theme = cursorTheme;
            cursor-size = cursorSize;
          };
        }
      ];
    };
  };

  # QT apps theming
  # might need to set global theme manualy with the KDE System Settings app
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Associate programs with file extensions
  xdg.mime =
    # List from /run/current-system/sw/share/applications
    let
      browser = "firefox.desktop";
      torrent = "org.qbittorrent.qBittorrent.desktop";
      imgviewer = "org.kde.gwenview.desktop";
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
      };
    };
}
