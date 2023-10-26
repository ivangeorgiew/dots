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
      }; 

      # Let home-manager install and manage itself
      programs.home-manager.enable = true;

      # reload systemd units when config changes
      systemd.user.startServices = "sd-switch";

      # GTK apps theming
      gtk = {
        enable = true;

        cursorTheme = {
          name = "macOS-BigSur";
          package = pkgs.apple-cursor;
          size = 24;
        };

        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-folders;
        };

        # https://github.com/catppuccin/gtk
        theme = {
          name = "Catppuccin-Mocha-Compact-Blue-Dark";
          package = pkgs.catppuccin-gtk.override {
            variant = "mocha";
            size = "compact";
            accents = [ "blue" ];
            tweaks = [ "rimless" "black" ];
          };
        };
      };

      # QT apps theming
      qt = {
        enable = true;
        platformTheme = "gtk";
        style.name = "adwaita-dark";
      };
    };
  };
}
