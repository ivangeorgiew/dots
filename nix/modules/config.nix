{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  nixpkgs = {
    # Add all overlays
    overlays = builtins.attrValues outputs.overlays;

    config = {
      # Allows using unfree programs
      allowUnfree = true;

      # Temporarily needed insecure packages
      permittedInsecurePackages = [ "openssl-1.1.1w" ];
    };
  };

  nix = {
    # Auto garbage collect
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Adds each flake input as registry to make nix3 command consistent
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Adds each flake input to system's legacy channel to make legacy nix commands consistent
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Removes duplicate files in the store automatically
      auto-optimise-store = true;

      # Enable new nix features
      experimental-features = [ "nix-command" "flakes" ];

      # Users which have rights to modify binary caches and other stuff
      trusted-users = [ "root" "@wheel" ];

      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org" 
      ];

      # Public keys for the above caches
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" 
      ];
    };
  };

  # Add shells to /etc/shells
  environment.shells = with pkgs; [ fish ];

  # Default shell for all users
  users.defaultUserShell = pkgs.fish;

  # User accounts. Don't forget to set a password with ‘passwd’.
  users.users.root.initialPassword = "123123";
  users.users."${username}" = {
    initialPassword = "123123";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "libvirtd" ];
  };

  systemd = {
    # Don't wait for NetworkManager
    services.NetworkManager-wait-online.enable = false;

    # Shorter timers for services
    extraConfig = "DefaultTimeoutStartSec=5s\nDefaultTimeoutStopSec=5s";
  };

  # Set your time zone.
  time.timeZone = "Europe/Sofia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "en_GB.UTF-8"; };

  # Setup the tty console
  console = { font = "Lat2-Terminus16"; useXkbConfig = true; };

  # Sound config for Pipewire
  sound.enable = false; #Disabled for pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    jack.enable = true; #Can be disabled
  };

  # Some apps might break without those
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  services.xserver = {
    # Enable autologin on boot
    displayManager.autoLogin = { enable = true; user = username; };

    # Configure keymap in X11
    extraLayouts.bgd = {
      description = "Bulgarian";
      languages = [ "bul" ];
      symbolsFile = ../xkb/bgd;
    };
    layout = "us,bgd";
    xkbVariant = "dvorak,";
    xkbOptions = "grp:shifts_toggle,ctrl:swapcaps";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}

