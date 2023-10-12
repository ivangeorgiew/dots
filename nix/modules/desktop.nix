{ inputs, outputs, lib, config, pkgs, ... }:
let
  hyprland-package = inputs.hyprland.packages.${pkgs.system}.hyprland-nvidia;
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
    #desktopManager.plasma5.enable = true;

    # Wayland handler for input devices (mouse, touchpad, etc.)
    libinput = {
      enable = true;
      mouse.accelProfile = "flat"; # disables mouse acceleration
    };

    # Enable proprietary Nvidia driver
    videoDrivers = [ "nvidia" ];
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

  # Env variables and packages
  environment = {
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
      polkit_gnome # for some apps to not crash
      qtwayland # requirement for qt5/6
    ];
  };

  # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/programs/hyprland.nix#L59
  # It sets a bunch of necessary things
  programs.hyprland = {
    enable = true;
    package = hyprland-package;
  };

  # More recent version of hyprland's xdg portal
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      xdg-hyprland-package
    ];
  };
}
