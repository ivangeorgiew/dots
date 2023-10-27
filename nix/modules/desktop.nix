{ inputs, outputs, lib, config, pkgs, ... }:
{
  services = {
    # Bad naming. Manages all the DE/WM settings, not only X11
    xserver = {
      enable = true;

      # Enable Gnome login manager
      displayManager.gdm.enable = true;

      # Enables KDE Plasma
      # desktopManager.plasma5.enable = true;

      # Wayland handler for input devices (mouse, touchpad, etc.)
      libinput = {
        enable = true;
        mouse.accelProfile = "flat"; # disables mouse acceleration
      };

      # Enable proprietary Nvidia driver
      videoDrivers = [ "nvidia" ];
    };

    # gnome keyring daemon (passwords/credentials)
    gnome.gnome-keyring.enable = true;
  };

  # OpenGL has to be enabled for Nvidia according to wiki
  hardware.opengl = { enable = true; driSupport = true; driSupport32Bit = true; };

  # Nvidia settings
  hardware.nvidia = {
    # Modesetting should be enabled almost always
    modesetting.enable = true;

    # Prevents problems with laptops and screen tearing
    powerManagement.enable = true;

    # Choose driver package
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Use the open source version
    open = false;

    # Auto installs nvidia-settings
    nvidiaSettings = true;

    # fix G-Sync / Adaptive Sync black screen issue
    forceFullCompositionPipeline = true;
  };

  # Wayland packages and env variables
  environment = {
    sessionVariables = {
      CLUTTER_BACKEND = "wayland";
      GBM_BACKEND = "nvidia-drm"; # Could crash Firefox
      GDK_BACKEND = "wayland,x11";
      LIBVA_DRIVER_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "xcb"; # Fixes Viber. Switch to "wayland;xcb" in the future
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland"; # might cause issues with older games
      WLR_DRM_NO_ATOMIC = "1"; # set if you have flickering issue
      WLR_NO_HARDWARE_CURSORS = "1";
      XCURSOR_SIZE = "24"; # set also in modules/home.nix -> gtk.cursorTheme.size
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Could cause issues with Discord and Zoom 
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";
    };

    systemPackages = with pkgs; [
      dunst # notifications
      ffmpeg_6 # for audio and video
      grim # screenshots for wayland
      pavucontrol # audio control
      playerctl # controls media players
      pcmanfm # GUI file manager
      lxde.lxmenu-data # list of installed apps when opening a file
      polkit_gnome # some apps require it
      libsForQt5.qt5.qtwayland # requirement for qt5
      qt6.qtwayland # requirement for qt6
      rofi-wayland # app launcher for wayland
      slurp # needed by `grim`
      swaybg # wallpapers for wayland
      wl-clipboard # copy/paste on wayland
      wf-recorder # screen recording
    ];

    shellAliases = {
      reboot = "echo 'Use the buttons'";
      shutdown = "echo 'Use the buttons'";
    };
  };

  programs = {
    # Enabling sets a bunch of necessary things
    # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/programs/hyprland.nix#L59
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland-nvidia;
    };

    # status bar for hyprland
    waybar = {
      enable = true;
      package = pkgs.unstable.waybar;
    };
  };

  # hyprland portal is auto added from programs.hyprland.enable
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
