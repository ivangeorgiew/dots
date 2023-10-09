{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  # Enable proprietary Nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];

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
}
