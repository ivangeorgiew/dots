{ inputs, lib, pkgs, username, graphicsCard, ... }:
{
  nix.settings = {
    substituters = lib.mkAfter [ "https://hyprland.cachix.org" ];
    trusted-public-keys = lib.mkAfter [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  services = {
    # Bad naming. Manages all the DE/WM settings, not only X11
    xserver = {
      enable = true;

      displayManager = {
        # Gnome display manager (login)
        gdm.enable = false;

        # disable the default login manager
        lightdm.enable = false;
      };
    };

    displayManager = {
      # whether to autologin
      autoLogin = { enable = false; user = username; };
    };

    # greetd display manager
    greetd = {
      enable = true;
      vt = 1;
      settings = {
        default_session = {
          command = "Hyprland -c /etc/nwg-hello/hyprland.conf";
          user = username;
        };
      };
    };

    # gnome keyring daemon (passwords/credentials)
    gnome.gnome-keyring.enable = true;

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = with pkgs; [
      gcr
      gnome.gnome-settings-daemon
    ];
  };

  # swaylock fix
  # https://discourse.nixos.org/t/swaylock-wont-unlock/27275
  security.pam.services.swaylock = { };
  security.pam.services.swaylock.fprintAuth = false;

  # Wayland packages and env variables
  environment = {
    sessionVariables = {
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland,x11";
      NIXOS_OZONE_WL = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland"; # might cause issues with older games
      WLR_DRM_NO_ATOMIC = "1"; # set if you have flickering issue
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";
    } // lib.optionalAttrs (graphicsCard == "nvidia") {
      GBM_BACKEND = "nvidia-drm"; # Could crash Firefox
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Could cause issues with Discord and Zoom
    };

    systemPackages = with pkgs; [
      dunst # notifications
      grim # screenshots for wayland
      kdePackages.qtwayland # requirement for qt6
      libsForQt5.qt5.qtwayland # requirement for qt5
      modified.mpvpaper # video wallpaper
      networkmanagerapplet # manage wifi
      playerctl # controls media players
      polkit_gnome # some apps require polkit
      rofi-wayland # app launcher for wayland
      slurp # needed by `grim`
      swaybg # wallpapers for wayland
      swaylock-effects # lock screen
      #modified.nwg-dock-hyprland # dock for hyprland
      modified.nwg-hello # login manager
      vulkan-tools # to debug issues with vulkan
      waybar # status bar
      wf-recorder # screen recording
      wl-clipboard # copy/paste on wayland
    ];

    shellAliases = {
      reboot = "echo 'Use the buttons'";
      shutdown = "echo 'Use the buttons'";
    };

    # Adds some needed folders in /run/current-system/sw
    # Example: /run/current-system/sw/share/wayland-sessions folder
    pathsToLink = [ "/share" ];

    etc = {
      # nwg-hello starting file
      "nwg-hello/hyprland.conf".text = ''
        monitor = , highrr, auto, 1
        bind = ALT SHIFT, q, killactive,
        misc {
          disable_hyprland_logo = true
        }
        animations {
          enabled = false
        }
        input {
          kb_model = pc104
          kb_layout = us,bgd
          kb_variant = dvorak,
          kb_options = grp:shifts_toggle,ctrl:swapcaps
          repeat_rate = 50
          repeat_delay = 300
          sensitivity = -0.75
          accel_profile = flat
        }
        exec-once = nwg-hello; hyprctl dispatch exit
      '';
    };
  };

  programs = {
    # Enabling sets a bunch of necessary things
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/programs/hyprland.nix#L59
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;

      # use latest xdg-desktop-portal-hyprland (currently v1.3.1)
      #portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };

    # GUI file manager
    thunar.enable = true;

    # app for gnome-keyring passwords management
    seahorse.enable = true;
  };

  services = {
    # for auto mounting of disks
    gvfs.enable = true;
    udisks2.enable = true;
    devmon.enable = true;

    # file manager thumbnail support for images
    tumbler.enable = true;
  };

  xdg.portal = {
    enable = true;

    # for the `xdg-open` command to use portals
    xdgOpenUsePortal = true;

    # add extra portals (hyprland portal is auto added)
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  # Polkit unit service
  # to start it use `systemctl --user start my-polkit-agent`
  systemd.user.services.my-polkit-agent = {
    description = "starts polkit agent";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
