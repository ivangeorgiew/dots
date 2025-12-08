{
  inputs,
  lib,
  pkgs,
  config,
  username,
  graphicsCard,
  ...
}: let
  use_uwsm = true; # make sure to enable/disable UWSM stuff in hyprland config
in {
  nix.settings = {
    # Add hyprland binary cache
    extra-substituters = lib.mkAfter ["https://hyprland.cachix.org"];
    extra-trusted-substituters = lib.mkAfter ["https://hyprland.cachix.org"];
    extra-trusted-public-keys = lib.mkAfter ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  services = {
    # X11 settings
    xserver = {
      enable = false;
      displayManager.lightdm.enable = false;
    };

    displayManager = {
      # Works only if a display manager is enabled
      autoLogin = {
        enable = false;
        user = username;
      };

      # Add .desktop entries from packages
      # Can later be accessed manually with `{service.displayManager.sessionData.desktops}/share`
      # sessionPackages = with pkgs; [ ];
    };

    # greetd display manager
    greetd = {
      enable = true;
      # vt = 1;

      settings = rec {
        # First login
        # Comment out if you want to require password on first login
        initial_session = {
          command =
            if use_uwsm
            then "uwsm start hyprland-uwsm.desktop"
            else "Hyprland";
          user = username;
        };

        # Subsequent logins
        default_session = let
          tuigreet_flags = lib.concatStringsSep " " [
            "--debug /tmp/tuigreet.log"
            "--asterisks"
            "--remember"
            "--remember-user-session"
            "--user-menu"
            "--time"
          ];
        in {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet ${tuigreet_flags}";
          user = "greeter";
        };
      };
    };

    # gnome keyring daemon (passwords/credentials)
    gnome.gnome-keyring.enable = true;
  };

  security.pam.services = {
    # swaylock fix
    # https://discourse.nixos.org/t/swaylock-wont-unlock/27275
    swaylock = {};
    swaylock.fprintAuth = false;

    # Unlock gnome-keyring on login with greetd
    # Works only if you use password to login
    # and have Default keyring created
    greetd.enableGnomeKeyring = true;
  };

  environment = {
    sessionVariables =
      # Generic
      {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1";
        NVD_BACKEND = "direct";
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11,*";
        QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        SDL_VIDEODRIVER = "wayland";
        # WLR_DRM_NO_ATOMIC = "1"; # set if you have flickering issue
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        __GL_GSYNC_ALLOWED = "1";
        __GL_VRR_ALLOWED = "1";
        HYPR_PLUGIN_DIR = pkgs.symlinkJoin {
          name = "hyprland-plugins";
          paths = with pkgs.hland; [
            # Use either plugins-git or plugins-nix
            plugins-git.hyprbars # titlebars on windows
          ];
        };
      }
      // lib.optionalAttrs use_uwsm {
        APP2UNIT_SLICES = "a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice";
        APP2UNIT_TYPE = "service";
      }
      # Nvidia related variables
      // lib.optionalAttrs (graphicsCard == "nvidia") {
        GBM_BACKEND = "nvidia-drm";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

    # Desktop related packages
    systemPackages = with pkgs; [
      # CLI apps
      dunst # notifications
      grim # screenshots for wayland
      kdePackages.qtwayland # requirement for qt6
      libsForQt5.qt5.qtwayland # requirement for qt5
      libsecret # used by seahorse and gnome-keyring
      mpvpaper # video wallpaper
      polkit_gnome # authentication for some apps
      slurp # needed by `grim`
      swaybg # wallpapers for wayland
      swaylock-effects # lock screen
      unstable.app2unit # UWSM related
      unstable.waybar # status bar
      vulkan-tools # to debug issues with vulkan
      virtualglLib # provides glxinfo for debugging
      wf-recorder # screen recording
      wl-clipboard # copy/paste on wayland

      # GUI apps
      unstable.hyprviz # GUI for configuring Hyprland
      networkmanagerapplet # manage wifi
      nwg-look # GTK theme changing
      nwg-icon-picker # GTK icons search
      playerctl # controls media players
      rofi-wayland # app launcher for wayland
    ];

    # Adds some needed folders in /run/current-system/sw
    # pathsToLink = ["/share/wayland-session"];
  };

  programs = {
    # Enabling sets a bunch of necessary things
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/programs/hyprland.nix#L59
    hyprland = {
      enable = true;

      # Use packages from the Hyprland input
      package = pkgs.hland.hypr-pkgs.hyprland;
      portalPackage = pkgs.hland.hypr-pkgs.xdg-desktop-portal-hyprland;

      # Enabled by default
      #xwayland.enable = true;

      # UWSM - https://wiki.hypr.land/Useful-Utilities/Systemd-start/#uwsm
      # If you do enable it - you have to change:
      # - startup command at top of this file
      # - the way all apps are started in hyprland config files
      withUWSM = use_uwsm;
    };

    uwsm.package = pkgs.custom.uwsm;

    # app for gnome-keyring passwords management
    seahorse.enable = true;
  };

  hardware.graphics = {
    # Use mesa from the hyprland input's nixpkgs commit to prevent issues
    package = pkgs.hland.nixpkgs.mesa;
    package32 = pkgs.hland.nixpkgs.driversi686Linux.mesa;
  };

  xdg.portal = {
    enable = true;

    # For the `xdg-open` command to use portals
    xdgOpenUsePortal = true;

    # Add extra portals (hyprland portal is auto added)
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];
  };

  systemd = let
    # Info: https://opensource.com/article/20/5/systemd-startup
    example_service = {
      enable = false; # true by default
      description = "Some description";
      wantedBy = ["default.target"]; # auto start and enable
      after = ["default.target"]; # start after another target
      before = ["default.target"]; # start before another target
      partOf = ["default.target"]; # restarts/stops if the target is restarted/stopped
      requisite = ["default.target"]; # requires the target to be running, but don't actually start it
      path = with pkgs; []; # adds /bin and /sbin subdirectories of packages to path for scripts
      environment = {}; # session variables

      # Better alternatives for pathing issues than the commented commands
      # Defined in: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/lib/systemd-unit-options.nix#L484
      script = ''echo "hello world"''; # ExecStart
      # preStop = ""; # ExecStop
      # postStop = ""; # ExecStopPost
      # reload = ""; # ExecReload
      # preStart = ""; # ExecStartPre
      # postStart = ""; # ExecStartPost

      # Info: https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html
      unitConfig = {};

      # Info: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html
      serviceConfig = {
        # `exec` - continue with other services once the process is STARTED
        # `oneshot` - continue with other services once the process is COMPLETED
        Type = "exec";

        # restart the service
        # preferrably with `Type = "exec"`
        # always - even on clean exit
        # on-failure - on crashes only
        #Restart = "on-failure";

        # consider the service active after it is done executing
        # preferrably with `Type = "oneshot"`
        #RemainAfterExit = "yes";

        # Which slice to run the unit at
        # `systemctl status --user` shows slices and units
        Slice = "background-graphical.slice";
      };
    };

    merge = lib.recursiveUpdate;

    common = {
      environment = {
        # Make sure that all apps are available (must use mkForce)
        # By default Nix fills PATH with some other dirs (not useful for custom services)
        PATH = lib.mkForce "/run/current-system/sw/bin:/run/current-system/sw/sbin:/run/wrappers/bin";
      };
      serviceConfig = {
        Slice = "background-graphical.slice";
      };
    };

    exec_common = merge common {
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      requisite = ["graphical-session.target"];
      serviceConfig = {
        Type = "exec";
        Restart = "always";
      };
    };
  in {
    # Add systemd services from packages
    # packages = with pkgs; [];

    # Creates services in /etc/systemd/user/
    user.services = {
      # Provides xdg autostart desktop file, but it requires
      # that the gnome DE is running so we have to manually start it
      polkit-agent = merge exec_common {
        description = "Polkit Agent";
        script = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      };

      reload-hypr = merge common {
        description = "Reload Hyprland and other services";
        after = ["graphical-session.target"];
        requisite = ["graphical-session.target"];
        script = "hyprctl reload";
        serviceConfig.Type = "oneshot";
      };

      waybar = merge exec_common {
        description = "Status bar for wayland";
        partOf = ["graphical-session.target" "reload-hypr.service"];
        after = ["graphical-session.target" "reload-hypr.service"];
        script = "waybar";
      };

      dunst = merge exec_common {
        description = "Notifications manager";
        partOf = ["graphical-session.target" "reload-hypr.service"];
        after = ["graphical-session.target" "reload-hypr.service"];
        script = "dunst";
      };

      mpvpaper = merge exec_common {
        enable = false;
        description = "Video as wallpaper";
        partOf = ["graphical-session.target" "reload-hypr.service"];
        after = ["graphical-session.target" "reload-hypr.service"];
        script = "mpvpaper -o 'no-audio loop' DP-1 ~/.config/livewall.mp4 >/dev/null";
      };

      wallpaper = merge exec_common {
        enable = true;
        description = "Set wallpaper";
        partOf = ["graphical-session.target" "reload-hypr.service"];
        after = ["graphical-session.target" "reload-hypr.service"];
        script = "swaybg -o DP-1 -m fill -i ~/.config/wall.png >/dev/null";
      };

      # Works, but is unneeded when using UWSM
      close-all-apps = merge exec_common {
        enable = false;
        description = "Close all apps on Hyprland gracefully";
        script = ''
          while true; do
            sleep 3
          done
        '';
        preStop = ''
          hyprctl -j clients \
            | jq -j '.[] | "dispatch closewindow address:\(.address); "' \
            | xargs -r hyprctl --batch
          sleep 1
        '';
        serviceConfig = {
          Type = "exec";
          Restart = "no";
        };
      };
    };

    # Creates services in /etc/systemd/system/
    # services = {};
  };
}
