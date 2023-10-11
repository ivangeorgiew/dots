# hyprland config is in modules/home.nix !!!

{ inputs, outputs, lib, config, pkgs, ... }:
let
  xrandrOpts = "--output DP-3 --primary --mode 1920x1080 --rate 240";
  xdg-hyprland-package = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
in
{
  # Bad naming. Manages all the DE/WM settings, not only X11
  services.xserver = {
    enable = true;

    # Enable Gnome login manager
    displayManager.gdm.enable = true;

    # gnome keyring daemon (passwords/credentials)
    gnome.gnome-keyring.enable = true;

    # Enables KDE Plasma
    desktopManager.plasma5.enable = false;

    # Wayland handler for input devices (mouse, touchpad, etc.)
    libinput = {
      enable = true;
      mouse.accelProfile = "flat"; # disables mouse acceleration
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-hyprland-package    
    ];
  };

  environment = {
    # Env variables
    sessionVariables = {
      # Wayland specific variables
      GBM_BACKEND = "nvidia-drm"; # Could crash Firefox
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Could cause issues with Discord and Zoom 
      __GL_GSYNC_ALLOWED = "1";
      __GL_VRR_ALLOWED = "1";
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_SESSION_TYPE = "wayland";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    # Packages
    systemPackages = with pkgs; [
      swww # animated wallpapers for wayland
      dunst # notifications
      bemenu # dmenu for wayland
      pcmanfm # GUI file manager
      grim # screenshots for wayland
      slurp # needed by `grim`
      ffmpeg_6 # for audio and video
      wl-clipboard # copy/paste on wayland
      pavucontrol # audio control
    ];
  };

  # for gnome related things
  programs.dconf.enable = true;
}
