{
  inputs,
  lib,
  pkgs,
  username,
  graphicsCard,
  ...
}: {
  nix.settings = {
    # Add hyprland binary cache
    extra-substituters = lib.mkAfter ["https://hyprland.cachix.org"];
    extra-trusted-public-keys = lib.mkAfter ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  services = {
    # X11 settings
    xserver = {
      enable = false;
      displayManager.lightdm.enable = false;
    };

    # Works only if a display manager is enabled
    displayManager.autoLogin = {
      enable = false;
      user = username;
    };

    # greetd display manager
    greetd = {
      enable = true;

      settings = let
        # start_command = "Hyprland";
        start_command = "uwsm start hyprland-uwsm.desktop";
      in {
        # First login
        initial_session = {
          command = start_command;
          user = username;
        };

        # If you logout or crash happens
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
            --asterisks --remember-session --user-menu --time \
            --cmd '${start_command}'";
          user = username;
        };
      };
    };

    # gnome keyring daemon (passwords/credentials)
    gnome.gnome-keyring.enable = true;

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
    ];

    # for auto mounting of disks
    gvfs.enable = true;
    udisks2.enable = true;
    devmon.enable = true;

    # file manager thumbnail support for images
    tumbler.enable = true;
  };

  # swaylock fix
  # https://discourse.nixos.org/t/swaylock-wont-unlock/27275
  security.pam.services = {
    swaylock = {};
    swaylock.fprintAuth = false;
  };

  environment = {
    sessionVariables =
      # Recommended by Hyprland
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
      }
      # Nvidia related variables
      // lib.optionalAttrs (graphicsCard == "nvidia") {
        GBM_BACKEND = "nvidia-drm";
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      }
      # Hyprland Plugins
      // {
        HYPR_PLUGIN_DIR = pkgs.symlinkJoin {
          name = "hyprland-plugins";
          paths = with pkgs.hland; [
            # Use either plugins-git or plugins-nix
            plugins-git.hyprbars # titlebars on windows
            plugins-git.hyprwinwrap # video/gif as wallpaper
          ];
        };
      };

    # Desktop related packages
    systemPackages = with pkgs; [
      # CLI apps
      dunst # notifications
      grim # screenshots for wayland
      kdePackages.qtwayland # requirement for qt6
      libsForQt5.qt5.qtwayland # requirement for qt5
      mpvpaper # video wallpaper
      polkit_gnome # some apps require polkit
      slurp # needed by `grim`
      swaybg # wallpapers for wayland
      swaylock-effects # lock screen
      unstable.app2unit # UWSM related
      unstable.waybar # status bar
      vulkan-tools # to debug issues with vulkan
      wf-recorder # screen recording
      wl-clipboard # copy/paste on wayland

      # GUI apps
      hland.hyprviz # GUI for configuring Hyprland
      networkmanagerapplet # manage wifi
      nwg-look # GTK theme changing
      nwg-icon-picker # GTK icons search
      playerctl # controls media players
      rofi-wayland # app launcher for wayland
    ];

    # Adds some needed folders in /run/current-system/sw
    # Example: /run/current-system/sw/share/wayland-sessions folder
    # pathsToLink = ["/share"];
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
      withUWSM = true;
    };

    # GUI file manager
    thunar.enable = true;

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

  systemd.user.services = {
    polkit-agent = {
      description = "Polkit Agent (user verification for apps)";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
