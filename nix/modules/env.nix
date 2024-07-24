{ inputs, outputs, lib, config, pkgs, username, ... }:
let
  iconTheme = "Papirus-Dark";
  themeName = "adw-gtk3-dark";
in
{
  environment = {
    systemPackages = with pkgs; [
      # CLI apps, tools and requirements
      adw-gtk3 # used for GTK theming
      bat # better alternative to cat
      btop # system monitor
      babelfish # translate bash scripts to fish
      cava # audio visualizer
      cmatrix # cool effect
      curl # download files
      dash # fastest shell
      devbox # version manager (npm, pnpm, go, python, etc)
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
      ncdu # windirstat for linux (sort dirs by size)
      nerdfix # removes obsolete nerd font icons
      nitch # alternative to neofetch
      p7zip # archiving and compression
      papirus-icon-theme # icons for GTK
      pavucontrol # audio control
      pstree # prints tree of pids
      ripgrep # newest silver searcher + grep
      shared-mime-info # add new custom mime types (check arch wiki)
      stow # symlink dotfiles
      tree # print folder tree structure
      tree-sitter # needed by neovim
      unzip # required by some programs
      wget # download files

      # GUI apps
      brave # browser
      celluloid # mpv with GUI (video player)
      easyeffects # sound effects
      firefox-bin # browser
      floorp # browser
      gedit # basic text editor GUI
      gnome.dconf-editor # to check GTK theming values
      google-chrome # browser
      keepassxc # password manager
      kitty # terminal
      libsForQt5.ark # 7-zip alternative
      libsForQt5.gwenview # image viewer
      mpv # video player
      nur.repos.nltch.spotify-adblock # spotify
      pinta # MS Paint for linux
      qbittorrent # torrent downloading
      unstable.viber # chat app
      vesktop # discord + additions

      # Languages and Package Managers
      (python310.withPackages(ps: with ps; [ requests pygobject3 pip ]))
      gobject-introspection # for some python scripts
      go
      lua51Packages.lua
      luarocks
      nodejs
      # cargo
      # php83Packages.composer
      # php
      # julia-bin
    ];

    localBinInPath = true; # add ~/.local/bin to PATH

    sessionVariables = rec {
      TERMINAL = "kitty";
      BROWSER = "floorp";
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
      ll = "ls -lah1"; # List files and directories
      rm = "rm -rI"; # Ask for each file before deleting
      mkdir = "mkdir -p"; # Make dirs recursively
      cp = "cp -r"; # Copy recursively
      cat = "bat"; # Show file contents
      p = "pnpm"; # use pnpm
      ps_search = "ps aux | rg"; # List a process
      ps_kill = "pkill -9"; # Force kill a process (hence the 9)
      nix-switch = "sudo nixos-rebuild switch --flake ~/dots/#"; # Change nixos config now
      nix-boot = "sudo nixos-rebuild boot --flake ~/dots/#"; # Change nixos config after boot
      nix-update-all = "sudo nix flake update ~/dots/#"; # Update the versions of packages
      nix-update = "update_nix_inputs"; # Update only specific flake inputs
      nix-list = "sudo nix profile history --profile /nix/var/nix/profiles/system"; # List nixos generations
      nix-roll = "sudo nix profile rollback --profile /nix/var/nix/profiles/system --to"; # Rollback to a generation
      nix-gc = "sudo nix profile wipe-history --profile /nix/var/nix/profiles/system && nix store gc"; # Garbage collect nixos
    };

    etc = {
      # GTK theming
      "gtk-2.0/gtkrc".text = ''
        gtk-icon-theme-name = "${iconTheme}"
        gtk-theme-name = "${themeName}"
      '';
      "gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-icon-theme-name=${iconTheme}
        gtk-theme-name=${themeName}
      '';
      "gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-icon-theme-name=${iconTheme}
        gtk-theme-name=${themeName}
      '';
    };
  };

  # Config/add packages
  programs = {
    # Interactive shell
    fish = {
      enable = true;

      useBabelfish = true; # Bash to Fish translation

      interactiveShellInit =
      let
        npm_global_dir = "~/.npm-global";
        npm_packages = "npm pnpm neovim";
      in ''
        function update_nix_inputs
          if count $argv > /dev/null
            set -l a (string join " --update-input " $argv)
            eval "sudo nix flake lock --update-input $a ~/dots/#"
          end
        end

        # Disable greeting
        set fish_greeting

        # Display system info
        # nitch

        # Hook direnv
        direnv hook fish | source

        # Setup npm if available
        if command -q npm
          # set the path for npm global packages
          if not grep -q ".npm-global" ~/.npmrc
            npm set prefix ${npm_global_dir}
          end

          # add the npm globals to PATH
          fish_add_path --path ${npm_global_dir}/bin

          # install/update npm global packages
          nohup npm i -g ${npm_packages} </dev/null &>/dev/null &
        end
      '';
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

    # java = {
    #   enable = true;
    #   # package = pkgs.jdk; # can be substituted to oracle version
    # };

    # fix dynamically linked binaries
    # for example: things installed from mason.nvim
    # might need to set:
    # environment.shellInit = ''
    #   export NIX_LD=${pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"}
    # ''
    nix-ld = {
      enable = true;
      # package = pkgs.nix-ld;
      # libraries = []; # extra libraries to include
    };

    # combined with devbox or a flake shell, autoloads
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

    # GTK theming
    dconf = {
      enable = true;

      # check different values with dconf-editor
      # example config: https://github.com/Electrostasy/dots/blob/c62895040a8474bba8c4d48828665cfc1791c711/profiles/system/gnome/default.nix#L123-L287
      profiles.user.databases = [{
        settings = {
          "org/gnome/desktop/interface" = {
            gtk-theme = themeName;
            icon-theme = iconTheme;
          };
        };
      }];
    };
  };

  # QT apps theming
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  # Associate programs with file extensions
  xdg.mime =
  # list from /run/current-system/sw/share/applications
  let
    browser = "floorp.desktop";
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
