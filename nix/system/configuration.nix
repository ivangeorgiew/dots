{ inputs, outputs, lib, config, pkgs, ... }:
{
  nixpkgs = {
    # Add all overlays
    overlays = builtins.attrValues outputs.overlays;

    config = {
      # Allows using unfree programs
      allowUnfree = true;

      # Temporarily needed insecure packages
      permittedInsecurePackages = [ "openssl-1.1.1v" ];
    };
  };

  nix = {
    # Adds each flake input as registry to make nix3 command consistent
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Adds each flake input to system's legacy channel to make legacy nix commands consistent
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Removes duplicate files in the store automatically
      auto-optimise-store = true;

      # Enable new nix features
      experimental-features = [ "nix-command" "flakes" ];
    };

    # Auto garbage collect
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Default shell for all users
  users.defaultUserShell = pkgs.fish;

  # User accounts. Don't forget to set a password with ‘passwd’.
  users.users.ivangeorgiew = {
    initialPassword = "123123";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Setup fonts
  fonts.fonts = with pkgs; [
    # includes only the icons from nerdfonts
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    dejavu_fonts
    source-code-pro
  ];

  # Setup QT app style
  #qt = {
  #  enable = true;
  #  platformTheme = "gtk2";
  #  style = "gtk2";
  #};

  environment = {
    # Add shells to /etc/shells
    shells = with pkgs; [ fish ];

    # Env variables
    variables = rec {
      EDITOR = "vim";
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
    };

    # Env aliases
    shellAliases = {
      l = "ls -l";
      ll = "ls -la";
      kl = "pkill -9"; # Force kill a process (hence the 9)
      ks = "ps aux | grep"; # List a process
      p = "pnpm";
      nix-up = "sudo nixos-rebuild switch --flake ~/dotfiles/nix/#"; # Change nixos config now
      nix-bt = "sudo nixos-rebuild boot --flake ~/dotfiles/nix/#"; # Change nixos config after boot
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}

