# To install from the LiveISO:
# sudo nixos-install --no-root-passwd --flake https://github.com/ivangeorgiew?dir=nix#mahcomp

# Initial password is 123123
# Don't forget to change the password main user with `passwd username`

# To update package versions:
# sudo nix flake update

# To update config:
# sudo nixos-rebuild switch --flake .#mahcomp

{
  description = "My NixOS flake config";

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
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs [
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
    nixosModules = import ./modules { inherit lib; };

    # Configurations
    nixosConfigurations.mahcomp = lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs outputs; };

      # Combine all my modules with other ones
      modules = (builtins.attrValues outputs.nixosModules) ++ [
        # If HiDPI is needed due to monitor (github.com/nixos/nixos-hardware)
        #inputs.hardware.nixosModules.common-hidpi
      ];
    };
  };
}
