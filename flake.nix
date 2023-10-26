# To install from the LiveISO:
# sudo nixos-install --no-root-passwd --flake https://github.com/ivangeorgiew/dots#mahcomp

# Initial password is 123123
# Don't forget to change the passwords of main user and root with `passwd username`

# Extra commands are shell aliases
{
  description = "My NixOS flake config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur/master";
    hyprland.url = "github:hyprwm/Hyprland";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    inherit (self) outputs;
    inherit (nixpkgs) lib;

    username = "ivangeorgiew";
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
    (system: import ./nix/pkgs { pkgs = nixpkgs.legacyPackages.${system}; });

    # Development shells to use through `nix develop`
    devShells = forAllSystems
    (system: import ./nix/shell.nix { pkgs = nixpkgs.legacyPackages.${system}; });

    # Package overlays
    overlays = import ./nix/overlays.nix { inherit inputs; };

    # NixOS Modules
    nixosModules = import ./nix/modules { inherit lib; };

    # Configurations
    nixosConfigurations.mahcomp = lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs outputs username; };
      modules = builtins.attrValues outputs.nixosModules;
    };
  };
}
