{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  networking = {
    # Change to per interface if using systemd-networkd
    useDHCP = lib.mkDefault true;
    #interfaces.enp30s0.useDHCP = lib.mkDefault true;
    #interfaces.wlp3s0f0u10.useDHCP = lib.mkDefault true;

    # Toggles IPv6
    enableIPv6 = false;

    # Define your hostname.
    hostName = "mahcomp";

    # Set DNS
    nameservers = [ "1.1.1.1" "1.0.0.1" ];

    # Toggles the firewall
    firewall.enable = false;

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
      "0.0.0.0" = [
        "online-go.com"
        # "9gag.com"
        # "www.youtube.com"
        # "www.reddit.com"
      ];
    };
  };
}
