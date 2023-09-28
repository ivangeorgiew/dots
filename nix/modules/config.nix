{ inputs, outputs, lib, config, pkgs, ... }:
let
  # For some reason, some of the options are not used by nix???
  btrfsOpts = [ "compress-force=zstd" "commit=60" "noatime" "ssd" "nodiscard" ];
  username = "ivangeorgiew";
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

  nixpkgs = {
    # Add all overlays
    overlays = builtins.attrValues outputs.overlays;

    config = {
      # Allows using unfree programs
      allowUnfree = true;

      # Temporarily needed insecure packages
      permittedInsecurePackages = [ "openssl-1.1.1v" ];
    };
  };

  nix = {
    # Auto garbage collect
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Adds each flake input as registry to make nix3 command consistent
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Adds each flake input to system's legacy channel to make legacy nix commands consistent
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Removes duplicate files in the store automatically
      auto-optimise-store = true;

      # Enable new nix features
      experimental-features = [ "nix-command" "flakes" ];

      # Users which have rights to modify binary caches and other stuff
      trusted-users = [ "root" "@wheel" ];

      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org" 
      ];

      # Public keys for the above caches
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" 
      ];
    };
  };

  # Default shell for all users
  users.defaultUserShell = pkgs.fish;

  # User accounts. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    initialPassword = "123123";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # Setup fonts
  fonts = {
    # Enables common fonts
    enableDefaultFonts = true;

    # Create dir with all fonts for compatibility
    fontDir.enable = true;

    fontconfig = {
      enable = true;
      includeUserConf = true; # ~/.config/fontconfig/fonts.conf

      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Noto Sans Mono" ];
        emoji = [ "Symbols Nerd Font" "Twitter Color Emoji" "Noto Color Emoji" ];
      };
    };

    # Font packages
    fonts = with pkgs; [
      # Nerd Fonts with icons
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "Iosevka" "FiraCode" "JetBrainsMono" "SourceCodePro" ]; })
      #(nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

      dejavu_fonts
      noto-fonts
      noto-fonts-emoji
      twitter-color-emoji
      #fira-code
      #fira-code-symbols
      #iosevka
      #source-code-pro
    ];
  };

  # Setup QT app style
  #qt = {
  #  enable = true;
  #  platformTheme = "gtk2";
  #  style = "gtk2";
  #};

  environment = {
    # Add shells to /etc/shells
    shells = with pkgs; [ fish ];

    # Env variables
    sessionVariables = rec {
      EDITOR = "vim";
      VISUAL = "vim";
      TERMINAL = "kitty";
      BROWSER = "google-chrome-stable";
      PATH = [ XDG_BIN_HOME ];
      HISTCONTROL = "ignoreboth:erasedups";
      LESSHISTFILE = "-";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_BIN_HOME = "$HOME/.local/bin";
      XDG_LIB_HOME = "$HOME/.local/lib";
    };

    # Env aliases
    shellAliases = {
      l = "ls -l";
      ll = "ls -la";
      kl = "pkill -9"; # Force kill a process (hence the 9)
      ks = "ps aux | grep"; # List a process
      p = "pnpm"; # Launch pnpm node package manager
      nix-up = "sudo nixos-rebuild switch --flake ~/dotfiles/nix/#"; # Change nixos config now
      nix-bt = "sudo nixos-rebuild boot --flake ~/dotfiles/nix/#"; # Change nixos config after boot
    };
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
      enable = true;

      # Disable wifi powersaving
      wifi.powersave = false;

      #If there are issues with the wifi
      ethernet.macAddress = "stable";
      wifi.macAddress = "stable";
    };

    hosts = {
      # blocked websites
      "127.0.0.1" = [
        "9gag.com"
        "online-go.com"
      ];
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

  services.xserver = {
    displayManager.autoLogin = { enable = true; user = username; };

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Don't touch
}

