{ inputs, outputs, username, lib, config, pkgs, ... }:
{
  # required for home-manager to work
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # global home-manager settings
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    extraSpecialArgs = { inherit inputs outputs username; };

    users."${username}" = _: {
      # Basic info
      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "23.05"; # Don't change

        # add local executables to PATH
        sessionPath = [ "$HOME/.local/bin" ];

        pointerCursor = {
          name = "macOS-BigSur";
          package = pkgs.apple-cursor;
          size = 24;
          gtk.enable = true;
          x11.enable = true;
        };
      };

      # Let home-manager install and manage itself
      programs.home-manager.enable = true;

      # reload systemd units when configuration changes
      systemd.user.startServices = "sd-switch";

      # enable fontconfig
      fonts.fontconfig.enable = true;

      # GTK apps theming
      gtk = {
        enable = true;

        gtk2.configLocation = "/home/${username}/.config/gtk-2.0/gtkrc";

        font = {
          name = "Inter";
          package = (pkgs.google-fonts.override { fonts = ["Inter"]; });
          size = 12;
        };

        iconTheme = {
          name = "Adwaita";
          package = pkgs.gnome.adwaita-icon-theme;
        };

        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
      };
    };
  };
}
