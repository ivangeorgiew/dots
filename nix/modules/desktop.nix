{ inputs, outputs, lib, config, pkgs, ... }:
let
  xrandrOpts = "--output DP-3 --primary --mode 1920x1080 --rate 240";
  hyprlandPackage = inputs.hyprland.packages.${pkgs.system}.hyprland;
  xdgHyprlandPackage = inputs.xdg-desktop-portal-hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
in
{
  # Bad naming. Manages all the DE/WM settings, not only X11
  services.xserver = {
    enable = true;

    displayManager = {
      #startx.enable = true;

      # SDDM/GDM settings
      sddm.enable = true;
      setupCommands = "${pkgs.xorg.xrandr}/bin/xrandr ${xrandrOpts}";
      #defaultSession = "none+bspwm";
    };

    # Enables KDE Plasma
    desktopManager.plasma5.enable = true;
  };

  environment = {
    # DE/WM specific variables
    sessionVariables = {
      # Wayland specific variables
      #GBM_BACKEND = "nvidia-drm"; # Could crash Firefox
      #LIBVA_DRIVER_NAME = "nvidia";
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Could cause issues with Discord and Zoom 
      #__GL_GSYNC_ALLOWED = "1";
      #__GL_VRR_ALLOWED = "1";
      #NIXOS_OZONE_WL = "1";
      #WLR_NO_HARDWARE_CURSORS = "1";
      #XDG_SESSION_TYPE = "wayland";
      #QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      #QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    # Packages for DE/WM
    systemPackages = with pkgs; [
      # hyprland related packages
      #xdgHyprlandPackage    

      #bspwm
      #sxhkd
      #nitrogen
      #polybar
      #rofi
      #pavucontrol
      #lxappearance
      #dunst
      #udiskie
    ];
  };

  # Predefined package configs
  programs = {
    hyprland = {
      enable = false;

      # Hyprland's own flake package
      #package = pkgs.hyprland;
      package = hyprlandPackage;
      
      # Better nvidia support
      nvidiaPatches = true;      

      # Xwayland settings
      xwayland = {
        enable = true;
        #hidpi = true;
      };
    };
  };
}
