# To install from the LiveISO:
# sudo nixos-install --no-root-passwd --flake https://github.com/ivangeorgiew?dir=nix#mahcomp

# Initial password is 123123
# Don't forget to change the password main user with `passwd username`

# To update config:
#sudo nixos-rebuild switch --flake .#mahcomp

{
  description = "My NixOS flake config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware/master";
    nur.url = "github:nix-community/nur/master";
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
    (system: import ./customPkgs { pkgs = nixpkgs.legacyPackages.${system}; });

    # Development shells to use through `nix develop`
    devShells = forAllSystems
    (system: import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; });

    # Package overlays
    overlays = import ./overlays.nix { inherit inputs; };

    # Modules to share with others
    nixosModules = import ./modules;

    # Configurations
    nixosConfigurations.mahcomp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs outputs; };
      modules = [
        # Include a module I made
        #outputs.nixosModules.example

        # Checkout the github:nixos/nixos-hardware for more goodies
        # If HiDPI is needed due to monitor
        #inputs.hardware.nixosModules.common-hidpi

        ./system/hardware.nix
        ./system/packages.nix
        ./system/configuration.nix
      ];
    };
  };
}