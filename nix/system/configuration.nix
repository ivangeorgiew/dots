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

  # User accounts. Don't forget to set a password with ‘passwd’.
  users.users.ivangeorgiew = {
    initialPassword = "123123";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Setup fonts
  #fonts.fonts = with pkgs; [
  #  noto-fonts-emoji
  #  dejavu_fonts
  #  liberation_ttf
  #  source-code-pro
  #  (nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })
  #];

  # Setup QT app style
  #qt = {
  #  enable = true;
  #  platformTheme = "gtk2";
  #  style = "gtk2";
  #};

  # Env variables
  environment.variables = rec {
    EDITOR = "vim";
    TERMINAL = "kitty";
    BROWSER = "google-chrome-stable";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_BIN_HOME = "$HOME/.local/bin";
    XDG_LIB_HOME = "$HOME/.local/lib";
    PATH = [ XDG_BIN_HOME ];
    HISTCONTROL = "ignoreboth:erasedups";
    LESSHISTFILE = "-";
  };

  # Env aliases
  environment.shellAliases = {
    l = "ls -l";
    ll = "ls -la";
    kl = "pkill -9"; # Force kill a process (hence the 9)
    ks = "ps aux | grep"; # List a process
    p = "pnpm";
    nix-up = "sudo nixos-rebuild switch --flake ~/dotfiles/nix/#"; # Change nixos config now
    nix-bt = "sudo nixos-rebuild boot --flake ~/dotfiles/nix/#"; # Change nixos config after boot
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}

