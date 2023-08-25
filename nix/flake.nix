# To install from the LiveISO:
# sudo nixos-install --flake https://github.com/ivangeorgiew#mahcomp

# Initial password is 123123
# Don't forget to set password for main user with `passwd username`

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

    # Package Overlays
    overlays = import ./overlays.nix { inherit inputs; };

    # Modules to share with others 
    nixosModules = import ./modules;

    # Configurations
    nixosConfigurations.mahcomp = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs outputs; };
      modules = [
        # My own overlays
        #outputs.nixosModules.example

        # Checkout the github:nixos/nixos-hardware for more goodies
        # If HiDPI is needed due to monitor
        #inputs.hardware.nixosModules.common-hidpi

        ./nixos/hardware.nix
        ./nixos/packages.nix
        ./nixos/configuration.nix
      ];
    };
  };
}
