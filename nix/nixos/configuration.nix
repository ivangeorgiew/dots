{ inputs, outputs, lib, config, pkgs, ... }:
{
  nixpkgs =
  {
    # Add all overlays
    overlays = builtins.attrValues outputs.overlays;

    # Allows using unfree programs
    config.allowUnfree = true;
  };

  nix =
  {
    # Adds each flake input as registry to make nix3 command consistent
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Adds each flake input to system's legacy channel to make legacy nix commands consistent
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings =
    {
      # Removes duplicate files in the store automatically
      auto-optimise-store = true;

      # Enable new nix features
      experimental-features = [ "nix-command" "flakes" ];
    };

    # Auto garbage collect
    gc =
    {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Shorter timers for services
  systemd.extraConfig = "DefaultTimeoutStartSec=5s\nDefaultTimeoutStopSec=5s";

  # Set your time zone.
  time.timeZone = "Europe/Sofia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "en_GB.UTF-8"; };

  # Setup the tty console
  console = { font = "Lat2-Terminus16"; useXkbConfig = true; };

  # User accounts. Don't forget to set a password with ‘passwd’.
  users.users.ivangeorgiew =
  {
    initialPassword = "123123";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Setup fonts
  #fonts.fonts = with pkgs;
  #[
  #  noto-fonts-emoji
  #  dejavu_fonts
  #  liberation_ttf
  #  source-code-pro
  #  (nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })
  #];

  # Setup QT app style
  #qt =
  #{
  #  enable = true;
  #  platformTheme = "gtk2";
  #  style = "gtk2";
  #};

  # Environment variables
  environment.variables =
  {
    EDITOR = "vim";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}

