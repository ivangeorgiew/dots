{ inputs, outputs, username, lib, config, pkgs, ... }:
{
  # required for home-manager to work
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # global home-manager settings
  home-manager = {
    useGlobalPackages = true;
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

      nixpkgs = {
        # Set the same overlays as for the nixos config
        overlays = outputs.overlays;

        config = {
          # Fix for https://github.com/nix-community/home-manager/issues/2942
          allowUnfreePredicate = _: true;
          allowUnfree = true;
        };
      };

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
        platformTheme = "qtct";
        style.name = "adwaita-dark";
      };

      # Let home-manager install and manage itself
      programs.home-manager.enable = true;
    };
  };
}
