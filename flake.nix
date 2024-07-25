# To install from the LiveISO:
# sudo nixos-install --no-root-passwd --flake https://github.com/ivangeorgiew/dots#mahcomp

# Initial password is 123123
# Don't forget to change the passwords of main user and root with `passwd username`

# Initially based on https://github.com/Misterio77/nix-starter-configs/tree/main/standard

{
  description = "My NixOS flake config";

  inputs = {
    # get newest commit for nixos-unstable from https://status.nixos.org/
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur/master";
    hyprland.url = "github:hyprwm/Hyprland/v0.37.1";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    # can add specific package version by getting info from https://www.nixhub.io/
    # pkgs-nodejs_20_9.url = "github:nixos/nixpkgs/a71323f68d4377d12c04a5410e214495ec598d4c";
    # then use: inputs.pkgs-nodejs_20_9.legacyPackages.${system}.nodejs_20
  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    inherit (self) outputs;
    inherit (nixpkgs) lib;

    forAllSystems = (func:
      nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ]
      (system: func nixpkgs.legacyPackages.${system})
    );
  in
  {
    # Custom packages, to use through `nix build`, `nix shell`, etc.
    packages = forAllSystems
    (pkgs: import ./nix/pkgs { inherit pkgs; });

    # Development shells to use through `nix develop`
    devShells = forAllSystems
    (pkgs: import ./nix/shell.nix { inherit pkgs; });

    # Package overlays
    overlays = import ./nix/overlays.nix { inherit inputs; };

    # NixOS Modules
    nixosModules = import ./nix/modules { inherit lib; };

    # Configurations
    nixosConfigurations = {
      mahcomp = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
          username = "ivangeorgiew";
          graphicsCard = "nvidia";
        };
        modules = (builtins.attrValues outputs.nixosModules) ++ [
          ./nix/modules/hardware-mahcomp.nix
        ];
      };
    };
  };
}
