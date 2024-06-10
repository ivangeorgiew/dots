{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  # Arch
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # For AMD cpu
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Full hardware support
  hardware.enableAllFirmware = true;

  # Kernel related settings.
  # Fixes for WiFi.
  # v4l2loopback is for OBS virtual camera
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-amd" "v4l2loopback" ];
  boot.kernelParams = [];
  boot.blacklistedKernelModules = [ "rtw88_8821cu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8821cu v4l2loopback ];
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];

  # Set linux kernel version. Defaults to LTS
  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  # Setup boot loader
  boot.loader = {
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

  # Regular btrfs scrub
  services.btrfs.autoScrub.enable = true;

  # regular trimming of the SSD
  services.fstrim = { enable = true; interval = "weekly"; };
}
