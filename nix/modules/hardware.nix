{ inputs, outputs, lib, config, pkgs, username, ... }:
let
  # For some reason, some of the options are not used by nix???
  btrfsOpts = [ "compress-force=zstd" "commit=60" "noatime" "ssd" "nodiscard" ];
in
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
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

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
}
