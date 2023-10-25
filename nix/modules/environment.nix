# Env variables and aliases
{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  environment = {
    sessionVariables = rec {
      TERMINAL = "kitty";
      BROWSER = "brave-browser";
      HISTCONTROL = "ignoreboth:erasedups";
      LESSHISTFILE = "-";
      PATH = [ XDG_BIN_HOME ];
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_LIB_HOME = "$HOME/.local/lib";
      XDG_STATE_HOME = "$HOME/.local/state"
      XDG_DESKTOP_DIR = "$HOME/Desktop"
      XDG_DOCUMENTS_DIR = "$HOME/Documents"
      XDG_DOWNLOADS_DIR = "$HOME/Downloads"
      XDG_VIDEOS_DIR = "$HOME/Videos"
      XDG_PICTURES_DIR = "$HOME/Pictures"
    };

    shellAliases = {
      l = "ls -l";
      ll = "ls -la";
      kl = "pkill -9"; # Force kill a process (hence the 9)
      ks = "ps aux | grep"; # List a process
      p = "pnpm"; # Launch pnpm node package manager
      nix-update = "sudo nix flake update"
      nix-switch = "sudo nixos-rebuild switch --flake ~/dots/#"; # Change nixos config now
      nix-boot = "sudo nixos-rebuild boot --flake ~/dots/#"; # Change nixos config after boot
      nix-list = "sudo nix profile history --profile /nix/var/nix/profiles/system"; # List nixos generations
      nix-gc = "sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 30d"; # Garbage collect nixos
    };
  };

  xdg.mime.defaultApplications = {
    "text/html" = "brave-browser.desktop";
    "x-scheme-handler/http" = "brave-browser.desktop";
    "x-scheme-handler/https" = "brave-browser.desktop";
    "x-scheme-handler/about" = "brave-browser.desktop";
    "x-scheme-handler/unknown" = "brave-browser.desktop";
  };
}
