# To install from the LiveISO:
# sudo nixos-install --no-root-passwd --flake https://github.com/ivangeorgiew?dir=nix#mahcomp

# Initial password is 123123
# Don't forget to change the password main user with `passwd username`

# To update config:
# sudo nixos-rebuild switch --flake .#mahcomp

# Initially based on https://github.com/Misterio77/nix-starter-configs
{
  description = "My NixOS flake config";

  # Equivalent of nix.settings
  nixConfig = {
    # Removes duplicate files in the store automatically
    auto-optimise-store = true;

    # Enable new nix features
    experimental-features = [ "nix-command" "flakes" ];

    # Users which have rights to modify binary caches and other stuff
    trusted-users = [ "root", "@wheel" ];

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

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur/master";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{ self, nixpkgs, nur, ... }:
  let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
      "i686-linux"
    ];
  in rec
  {
    # Custom packages, to use through `nix build`, `nix shell`, etc.
    packages = forAllSystems
    (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });

    # Development shells to use through `nix develop`
    devShells = forAllSystems
    (system: import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; });

    # Package overlays
    overlays = import ./overlays.nix { inherit inputs; };

    # Modules
    nixosModules = import ./modules;

    # Configurations
    nixosConfigurations.mahcomp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs outputs; };

      # Include all my modules and a list of others
      modules = (builtins.attrValues outputs.nixosModules) ++ [
        # If HiDPI is needed due to monitor (github.com/nixos/nixos-hardware)
        #inputs.hardware.nixosModules.common-hidpi
      ];
    };
  };
}
