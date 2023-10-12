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
      # Add my dot files
      imports = [ ../../homeDots ];

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

      # Let home-manager install and manage itself
      programs.home-manager.enable = true;
    };
  };
}
