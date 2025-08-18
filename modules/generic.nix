{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  nixpkgs = {
    # Add all overlays
    overlays = builtins.attrValues outputs.overlays;

    config = {
      # Allows using unfree programs
      allowUnfree = true;

      # Temporarily needed insecure packages
      permittedInsecurePackages = [
        # "openssl-1.1.1w" # for viber
      ];
    };
  };

  nix = {
    # Auto garbage collect
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Adds each flake input as registry to make nix3 command consistent
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Adds each flake input to system's legacy channel to make legacy nix commands consistent
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Faster nix changes, but works only with Determinate Nix
      #lazy-trees = true;

      # Used by default in Determinate Nix
      #always-allow-substitutes = true;

      # Used by default in Determinate Nix
      max-jobs = "auto";

      # Removes duplicate files in the store automatically
      auto-optimise-store = true;

      # Enable new nix features
      extra-experimental-features = [ "nix-command" "flakes" ];

      # Users which have rights to modify binary caches and other stuff
      extra-trusted-users = [ "root" "@wheel" ];

      # Binary caches
      extra-trusted-substituters = [ "https://nix-community.cachix.org" ];

      # Public keys for the above caches
      extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
  };

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

  services = {
    # Configure keymaps
    xserver.xkb = {
      extraLayouts.bgd = {
        description = "Bulgarian";
        languages = [ "bul" ];
        symbolsFile = ../xkb/bgd;
      };
      layout = "us,bgd";
      variant = "dvorak,";
      options = "grp:shifts_toggle,ctrl:swapcaps";
    };

    # handler for input devices (mouse, touchpad, etc.)
    libinput = {
      enable = true;
      mouse.accelProfile = "flat"; # disables mouse acceleration
    };

    # toggles flatpak
    flatpak.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}

