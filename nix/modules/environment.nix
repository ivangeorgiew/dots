{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      # CLI apps and tools
      btop # system monitor
      cava # audio visualizer
      cmatrix # cool effect
      curl # download files
      ncdu # windirstat for linux (sort dirs by size)
      dash # fastest shell
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
      pstree # prints tree of pids
      ripgrep # newest silver searcher + grep
      shared-mime-info # add new custom mime types (check arch wiki)
      stow # symlink dotfiles
      tree-sitter # needed by neovim
      unzip # required by some programs
      wget # download files

      # GUI apps
      brave # browser
      celluloid # mpv with GUI (video player)
      #easyeffects # sound effects
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
    ];

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
      kl = "pkill -9"; # Force kill a process (hence the 9)
      ks = "ps aux | grep"; # List a process
      rm = "rm -rI"; # Ask for each file before deleting
      mkdir = "mkdir -p"; # Make dirs recursively
      cp = "cp -r"; # Copy recursively
      p = "pnpm"; # Launch pnpm node package manager
      nix-switch = "sudo nixos-rebuild switch --flake ~/dots/#"; # Change nixos config now
      nix-boot = "sudo nixos-rebuild boot --flake ~/dots/#"; # Change nixos config after boot
      nix-update-all = "sudo nix flake update ~/dots/#"; # Update the versions of packages
      nix-update = "nix_update"; # Update only specific flake inputs
      nix-list = "sudo nix profile history --profile /nix/var/nix/profiles/system"; # List nixos generations
      nix-roll = "sudo nix profile rollback --profile /nix/var/nix/profiles/system --to"; # Rollback to a generation
      nix-gc = "sudo nix profile wipe-history --profile /nix/var/nix/profiles/system && nix store gc"; # Garbage collect nixos
      nix-edit = "nix edit -f \"<nixpkgs>\""; # Check the source code of a package
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
        npm_packages = "npm pnpm neovim typescript";
      in ''
        function nix_update
          if count $argv > /dev/null
            sudo nix flake lock --update-input (string join " --update-input " $argv) ~/dots/#
          end
        end

        #Disable greeting
        set fish_greeting

        # Display system info
        nitch

        # set the path for npm global packages
        npm set prefix ${npm_global_dir}

        # add the npm globals to PATH
        fish_add_path --path ${npm_global_dir}/bin

        # install npm global packages
        nohup npm i -g ${npm_packages} </dev/null &>/dev/null &
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
