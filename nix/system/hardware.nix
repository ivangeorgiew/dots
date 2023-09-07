{ config, pkgs, lib, ... }:
let
  # For some reason, some of the options are not used by nix???
  btrfsOpts = [ "compress-force=zstd" "commit=60" "noatime" "ssd" "nodiscard" ];
  xrandrOpts = "--output DP-3 --primary --mode 1920x1080 --rate 240";
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
  boot.kernelParams = [];
  boot.blacklistedKernelModules = [ "rtw88_8821cu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821cu ];
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];

  # Set linux kernel version. Defaults to LTS
  boot.kernelPackages = pkgs.linuxPackages_6_4;

  # Setup boot loader
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;

    timeout = 15; # null to disable

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true; 
      useOSProber = true;
    };
  };

  # Configure partitions
  fileSystems."/" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=@root" ]; };
  fileSystems."/home" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=@home" ]; };
  fileSystems."/nix" = { device = "/dev/disk/by-label/NIX_ROOT"; fsType = "btrfs"; options = btrfsOpts ++ [ "subvol=@nix" ]; };
  fileSystems."/boot" = { device = "/dev/disk/by-label/NIX_BOOT"; fsType = "vfat"; };
  swapDevices = [ { device = "/dev/disk/by-label/NIX_SWAP"; } ];

  # Enable zram
  zramSwap.enable = true;

  # Regular btrfs scrub
  services.btrfs.autoScrub.enable = true;

  # regular trimming of the SSD
  services.fstrim = { enable = true; interval = "weekly"; };

  networking = {
    # Change to per interface if using systemd-networkd
    useDHCP = lib.mkDefault true;
    #interfaces.enp30s0.useDHCP = lib.mkDefault true;
    #interfaces.wlp3s0f0u10.useDHCP = lib.mkDefault true;

    # Define your hostname.
    hostName = "mahcomp";

    # Set DNS
    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    # Disable IPv6
    enableIPv6 = false;

    # Don't wait to have an IP
    dhcpcd.wait = "background";
    dhcpcd.extraConfig = "noarp"; 

    # Configure NetworkManager
    networkmanager = {
      # Use NetworkManager
      enable = true;

      # Disable wifi powersaving
      wifi.powersave = false;

      #If there are issues with the wifi
      ethernet.macAddress = "stable";
      wifi.macAddress = "stable";
    };
  };

  # Sound config for Pipewire
  sound.enable = false; #Disabled for pipewire
  security.rtkit.enable = true; #Optional but recommended
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; #Can be disabled
  };

  # X11 settings
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Login manager settings
    displayManager = {
      sddm.enable = true;
      autoLogin = { enable = true; user = "ivangeorgiew"; };
      setupCommands = "${pkgs.xorg.xrandr}/bin/xrandr ${xrandrOpts}";
      #defaultSession = "none+bspwm";
    };

    # Enable the Plasma 5 Desktop Environment.
    desktopManager.plasma5.enable = true;

    # Enable bspwm
    #windowManager.bspwm.enable = true;

    # Configure keymap in X11
    extraLayouts.bgd = {
      description = "Bulgarian";
      languages = [ "bul" ];
      symbolsFile = ../xkb/bgd;
    };
    layout = "us,bgd";
    xkbVariant = "dvorak,";
    xkbOptions = "grp:shifts_toggle,ctrl:swapcaps";

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

  systemd = {
    # Don't wait for NetworkManager
    services.NetworkManager-wait-online.enable = false;

    # Shorter timers for services
    extraConfig = "DefaultTimeoutStartSec=5s\nDefaultTimeoutStopSec=5s";
  };

  # Set your time zone.
  time.timeZone = "Europe/Sofia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "en_GB.UTF-8"; };

  # Setup the tty console
  console = { font = "Lat2-Terminus16"; useXkbConfig = true; };
}
