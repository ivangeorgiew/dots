{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  # Set your time zone.
  time.timeZone = "Europe/Sofia";

  # Arch
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    # For AMD cpu
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Full hardware support
    enableAllFirmware = true;

    # OpenGL has to be enabled for Nvidia according to wiki
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      # fixes some applications (but maybe can break others?)
      #setLdLibraryPath = true;

      extraPackages = with pkgs; [
        libva
        vaapiVdpau
        libvdpau-va-gl
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # Nvidia settings
    nvidia = {
      # Modesetting should be enabled almost always
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Choose driver package
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      # Use the open source version
      open = false;

      # Auto installs nvidia-settings
      nvidiaSettings = true;

      # fix G-Sync / Adaptive Sync black screen issue
      # disable if it's not needed because of worse performance
      #forceFullCompositionPipeline = true;
    };
  };

  # Kernel related settings.
  # Fixes for WiFi.
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [];
    };

    kernelModules = [ "kvm-amd" "v4l2loopback" ]; # v4l2loopback is for OBS virtual camera
    kernelParams = [];
    blacklistedKernelModules = [ "rtw88_8821cu" ];
    extraModulePackages = with config.boot.kernelPackages; [ rtl8821cu v4l2loopback ];
    supportedFilesystems = [ "btrfs" "ntfs" ];

    # Set linux kernel version. Defaults to LTS
    #kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

    # Setup boot loader
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      timeout = 10; # null to disable
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 10;
      };
    };
  };

  # Configure partitions
  fileSystems =
  let
    # For some reason, some of the options are not used by nix???
    btrfsOpts = [ "compress-force=zstd" "commit=60" "noatime" "ssd" "nodiscard" ];
    ntfsOpts = [ "commit=60" "noatime" "ssd" "nodiscard" "rw" "uid=1000" "gid=100" "iocharset=utf8" ];
  in {
    "/" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=@root" ]; };
    "/home" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=@home" ]; };
    "/nix" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=@nix" ]; };
    "/boot" = { device = "/dev/disk/by-label/NIX_BOOT"; fsType = "vfat"; };
    # "/run/media/c" = { device = "/dev/disk/by-uuid/825AEDFB5AEDEC3B"; fsType = "ntfs-3g"; options = ntfsOpts; };
    # "/run/media/d" = { device = "/dev/disk/by-uuid/01D99A27C60FB320"; fsType = "ntfs-3g"; options = ntfsOpts; };
  };
  swapDevices = [ { device = "/dev/disk/by-label/NIX_SWAP"; } ];

  # Enable zram
  zramSwap.enable = true;

  # set keyboard name for waybar module
  # output of `hyprctl devices`
  environment.sessionVariables = {
    "KEYBOARD_NAME" = "kingston-hyperx-alloy-fps-pro-mechanical-gaming-keyboard";
  };

  services = {
    # Regular btrfs scrub
    btrfs.autoScrub.enable = true;

    # regular trimming of the SSD
    fstrim = { enable = true; interval = "weekly"; };

    # Enable proprietary Nvidia driver
    xserver.videoDrivers = [ "nvidia" ];
  };
}
