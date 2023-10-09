# To install from the LiveISO:
# sudo nixos-install --no-root-passwd --flake https://github.com/ivangeorgiew?dir=nix#mahcomp

# Initial password is 123123
# Don't forget to change the passwords of main user and root with `passwd username`

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
    nix-colors.url = "github:misterio77/nix-colors";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
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

    username = "ivangeorgiew";
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

    # NixOS Modules
    nixosModules = import ./modules { inherit lib; };

    # Configurations
    nixosConfigurations.mahcomp = lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs outputs username; };

      # All of my nixos modules
      modules = builtins.attrValues outputs.nixosModules;
    };
  };
}
