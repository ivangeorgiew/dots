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
      # Toggles the git tree is dirty warning
      warn-dirty = false;

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
    # https://wiki.nixos.org/wiki/Nix-ld
    # Fix dynamically linked binaries
    # for example: things installed from mason.nvim
    # might need to set:
    # environment.shellInit = ''
    #   export NIX_LD=${pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"}
    # ''
    nix-ld = let
      # lua_ls_libs = pkgs.symlinkJoin {
      #   name = "lua_ls_libs";
      #   paths = with pkgs; [libunwind libbfd_2_38];
      #   postBuild = ''
      #     mkdir -p $out/lib
      #     ln -s ${pkgs.libbfd_2_38}/lib/libbfd-2.38.so $out/lib/libbfd-2.38-system.so
      #   '';
      # };
    in {
      enable = true;
      # package = pkgs.nix-ld;
      # Extra libraries to include
      # libraries = lib.mkAfter (with pkgs; [lua_ls_libs]);
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
    rtkit.enable = true;

    polkit = {
      enable = true;
      extraConfig = ''
        // Allow udisks2 to mount devices without authentication
        // for users in the "wheel" group.
        polkit.addRule(function(action, subject) {
          if ((action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
            action.id == "org.freedesktop.udisks2.filesystem-mount") &&
            subject.isInGroup("wheel")
          ) { return polkit.Result.YES; }
        });
      '';
    };
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
      layout = "us,bgd";
      variant = "dvorak,";
      options = "grp:shifts_toggle"; # ctrl:nocaps or ctrl:swapcaps can be used
      # used on Wayland too
      extraLayouts.bgd = {
        description = "Bulgarian";
        languages = ["bul"];
        symbolsFile = ../xkb/bgd;
      };
    };

    interception-tools = {
      # CapsLock maps to both Esc (pressed alone) and Ctrl (when held)
      enable = true;

      # plugins = with pkgs; [ interception-tools-plugins.caps2esc ]; # the default

      # Default `udevmonConfig` is broken in nixpkgs
      udevmonConfig = ''
        - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
          DEVICE:
            EVENTS:
              EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
      '';
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

    # Populates /bin and /usr/bin as on other Linux distros
    envfs.enable = true;

    # for auto mounting of disks
    gvfs.enable = true;
    udisks2.enable = true;

    dbus.packages = with pkgs; [
      gnome2.GConf # used by very old apps
    ];

    # Network File Sharing
    # https://nixos.wiki/wiki/Samba
    # https://gist.github.com/vy-let/a030c1079f09ecae4135aebf1e121ea6
    samba = {
      enable = true;
      openFirewall = true;
      nmbd.enable = false;
      settings = {
        global = {
          "security" = "user";
          "hosts allow" = "192.168.0. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        "public" = {
          "path" = "/run/media/c/Users/Public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
        };
      };
    };
    avahi = {
      enable = true;
      openFirewall = true;
      publish.enable = true;
      publish.userServices = true;
      # nssmdns4 = true;
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}
