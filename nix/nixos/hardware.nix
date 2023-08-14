{ config, pkgs, lib, ... }:
let
  # For some reason, some of the options are not used by nix???
  btrfsOpts = [ "compress-force=zstd:2" "commit=60" "noatime" "ssd" "nodiscard" ];
in
{
  # Arch
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # For AMD cpu
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Full hardware support
  hardware.enableAllFirmware = true;

  # Kernel related settings. Fixes for WiFi
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [ "nvidia_drm.modeset=1" ]; #hopeful fix
  boot.blacklistedKernelModules = [ "rtw88_8821cu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821cu ];
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];

  # Set linux kernel version. Defaults to LTS
  boot.kernelPackages = pkgs.linuxPackages_6_4;

  # Setup boot loader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub =
  {
    device = "nodev";
    efiSupport = true; 
    useOSProber = true;
  };

  # Configure partitions
  fileSystems."/" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=root" ]; };
  fileSystems."/home" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=home" ]; };
  fileSystems."/nix" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=nix" ]; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/NIX_BOOT"; fsType = "vfat"; };
  swapDevices = [ { device = "/dev/disk/by-label/NIX_SWAP"; } ];

  # Enable zram
  zramSwap.enable = true;

  # Regular btrfs scrub
  services.btrfs.autoScrub.enable = true;

  # regular trimming of the SSD
  services.fstrim = { enable = true; interval = "weekly"; };

  # Change to per interface if using systemd-networkd
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp30s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0f0u10.useDHCP = lib.mkDefault true;

  # Define your hostname.
  networking.hostName = "mahcomp";

  # Configure networking
  networking.networkmanager =
  {
    # Use NetworkManager
    enable = true;

    #If there are issues with the wifi
    #ethernet.macAddress = "permanent";
    #wifi.macAddress = "permanent";
    #wifi.scanRandMacAddress = false;
  };

  # Set DNS
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  # Sound config for Pipewire
  sound.enable = false; #Disabled for pipewire
  security.rtkit.enable = true; #Optional but recommended
  services.pipewire =
  {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; #Can be disabled
  };

  # X11 settings
  services.xserver =
  {
    # Enable the X11 windowing system.
    enable = true;

    # Login manager settings
    displayManager =
    {
      sddm.enable = true;
      autoLogin = { enable = true; user = "kawerte"; };
      setupCommands =
      ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --primary --mode 1920x1080 --rate 60
      '';
    };

    # Enable the Plasma 5 Desktop Environment.
    desktopManager.plasma5.enable = true;

    # Enable bspwm
    #windowManager.bspwm.enable = true;

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "ctrl:swapcaps";

    # Enable proprietary Nvidia driver
    #videoDrivers = [ "nvidia" ];
  };

  # OpenGL has to be enabled for Nvidia according to wiki
  hardware.opengl = { enable = true; driSupport = true; driSupport32Bit = true; };

  # Nvidia settings
  hardware.nvidia =
  {
    # Modesettings is required by most Wayland compositors
    modesetting.enable = true;

    # Choose driver package
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Use the open source version
    open = false;

    # Auto installs nvidia-settings
    nvidiaSettings = true;
  };
}
