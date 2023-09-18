{ inputs, outputs, lib, config, pkgs, ... }:
let
  xrandrOpts = "--output DP-3 --primary --mode 1920x1080 --rate 240";
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
      defaultSession = "none+bspwm";
    };

    # Enables KDE Plasma
    desktopManager.plasma5.enable = true;
  };

  environment = {
    # DE/WM specific variables
    sessionVariables = {
      # Wayland specific variables
      #NIXOS_OZONE_WL = "1";
      #LIBVA_DRIVER_NAME = "nvidia";
      #XDG_SESSION_TYPE = "wayland";
      #WLR_NO_HARDWARE_CURSORS = "1";

      # Disabled wayland variables, enable if necessary
      #GBM_BACKEND = "nvidia-drm"; # Could crash Firefox
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia"; # Could cause issues with Discord and Zoom 
    };

    # Packages for DE/WM
    systemPackages = with pkgs; [
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
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      
      # Better nvidia support
      enableNvidiaPatches = true;      

      # Xwayland settings
      xwayland = {
        enable = true;
        #hidpi = true;
      };
    };
  };
}
