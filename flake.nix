# Initially based on https://github.com/Misterio77/nix-starter-configs/tree/main/standard
{
  description = "My NixOS flake config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland/v0.37.1";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";

    # Hardware settings for laptops
    # nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    inherit (self) outputs;
    inherit (nixpkgs) lib;

    system = "x86_64-linux";

    # Probably don't need unfree packages here
    #(import nixpkgs { inherit system; config.allowUnfree = true; })
    forAllSystems = (
      func:
        lib.genAttrs ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"] (
          system: func nixpkgs.legacyPackages.${system}
        )
    );
  in {
    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    # Custom packages, to use through `nix build`, `nix shell`, etc.
    # packages = forAllSystems
    # (pkgs: import ./pkgs.nix { inherit pkgs; });

    # Flake templates
    # templates.default = {
    #   description = "Default shell template";
    #   path = ./shell-template;
    # };

    # Package overlays
    overlays.default = import ./overlays.nix {inherit inputs;};

    # NixOS Modules
    nixosModules = import ./modules {inherit lib;};

    # Configurations
    nixosConfigurations = {
      mahcomp = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs outputs;
          username = "ivangeorgiew";
          graphicsCard = "nvidia";
        };
        modules = (builtins.attrValues outputs.nixosModules) ++ [./modules/hardware-mahcomp.nix];
      };
    };
  };
}
