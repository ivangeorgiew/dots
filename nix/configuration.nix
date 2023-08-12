# Install command:
# nixos-install --no-root-passwd

# List generations:
# nix-env -p /nix/var/nix/profiles/system --list-generations

# Delete generations:
# nix-env -p /nix/var/nix/profiles/system --delete-generations (+2 || old || 3 4 5)

# Switch to generation:
# nix-env -p /nix/var/nix/profiles/system --switch-generation 7

# Actual config start:
{ config, pkgs, lib, modulesPath, ... }:
let
  nurTarball = builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz";
in
{
  # Imports
  imports = [ ./hardware.nix ];

  nixpkgs.config =
  {
    # Allows using unfree programs
    allowUnfree = true;

    # Adds NUR (AUR but for NixOS)
    packageOverrides = pkgs:
    {
      nur = import nurTarball { inherit pkgs; };
    };
  };

  nix.settings =
  {
    # Removes duplicate files in the store automatically
    auto-optimise-store = true;

    # Enable new nix features
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Auto garbage collect
  nix.gc =
  {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
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
  users.users.kawerte =
  {
    initialPassword = "123123";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    packages = with pkgs; [];
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

  # Packages
  environment.systemPackages = with pkgs;
  [
    # Dev tools
    vim
    wget
    curl
    git
    unzip
    gh

    # GUI apps
    keepassxc
    google-chrome
    #kitty
    #arandr

    # Just use the (browser app + ublock) instead
    #spotify
    #nur.repos.instantos.spotify-adblock

    # DE/WM apps
    #bspwm
    #sxhkd
    #nitrogen
    #polybar
    #rofi
    #pavucontrol
    #killall
    #lxappearance
    #dunst
    #udiskie
  ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

