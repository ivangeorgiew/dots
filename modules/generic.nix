{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  username,
  ...
}: {
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
    # Instead of this programs.nh.clean is used below
    # Auto garbage collect
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 7d";
    # };

    # Adds each flake input as registry to make nix3 command consistent
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # Adds each flake input to system's legacy channel to make legacy nix commands consistent
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Used by default in Determinate Nix
      max-jobs = "auto";

      # Removes duplicate files in the store automatically
      auto-optimise-store = true;

      # Enable new nix features
      extra-experimental-features = ["nix-command" "flakes"];

      # Users which have rights to modify binary caches and other stuff
      extra-trusted-users = ["root" "@wheel"];

      # Binary caches (yes we want substituters, not trusted-substituters)
      extra-substituters = ["https://nix-community.cachix.org"];

      # Public keys for the above caches
      extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };
  };

  programs = {
    # Fix dynamically linked binaries
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

    # Better nix CLI
    nh = {
      enable = true;

      # package = pkgs.nh;

      flake = "/home/${username}/dots"; # sets NH_OS_FLAKE variable

      # Better garbage collection
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 3 --keep-since 15d";
      };
    };
  };

  # User accounts. Don't forget to set a password with ‘passwd’.
  users.users.root.initialPassword = "123123";
  users.users."${username}" = {
    initialPassword = "123123";
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "audio" "libvirtd"];
  };

  systemd = {
    # Don't wait for NetworkManager
    services.NetworkManager-wait-online.enable = false;

    # Shorter timers for services
    extraConfig = "DefaultTimeoutStartSec=5s\nDefaultTimeoutStopSec=5s\nDefaultTimeoutAbortSec=5s";
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {LC_TIME = "en_GB.UTF-8";};

  # Setup the tty console
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Some apps might break without those
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  services = {
    # Sound config for Pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      jack.enable = true; #Can be disabled
    };

    # Configure keymaps on X11 and TTY console
    # due to the console.useXkbConfig option
    xserver.xkb = {
      extraLayouts.bgd = {
        description = "Bulgarian";
        languages = ["bul"];
        symbolsFile = ../xkb/bgd;
      };
      layout = "us,bgd";
      variant = "dvorak,";
      options = "grp:shifts_toggle,ctrl:swapcaps";
    };

    # Handler for input devices (mouse, touchpad, etc.)
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat"; # disables mouse acceleration
        accelSpeed = "-0.75"; # same as my Windows sensitivity
      };
    };

    # Toggles flatpak
    flatpak.enable = false;

    # Creates /bin and /usr/bin as on other Linux distros
    envfs.enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}
