{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  environment = {
    # Add shells to /etc/shells
    shells = with pkgs; [ fish ];

    # variables
    sessionVariables = rec {
      TERMINAL = "kitty";
      BROWSER = "google-chrome-stable";
      PATH = [ XDG_BIN_HOME ];
      HISTCONTROL = "ignoreboth:erasedups";
      LESSHISTFILE = "-";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_LIB_HOME = "$HOME/.local/lib";
      XDG_STATE_HOME = "$HOME/.local/state"
    };

    # aliases
    shellAliases = {
      l = "ls -l";
      ll = "ls -la";
      kl = "pkill -9"; # Force kill a process (hence the 9)
      ks = "ps aux | grep"; # List a process
      p = "pnpm"; # Launch pnpm node package manager
      nix-up = "sudo nixos-rebuild switch --flake ~/dotfiles/nix/#"; # Change nixos config now
      nix-bt = "sudo nixos-rebuild boot --flake ~/dotfiles/nix/#"; # Change nixos config after boot
      nix-list = "sudo nix profile history --profile /nix/var/nix/profiles/system"; # List nixos generations
      nix-gc = "sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 30d"; # Garbage collect nixos
    };
  };
}
