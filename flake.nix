# Initially based on https://github.com/Misterio77/nix-starter-configs/tree/main/standard
{
  description = "My NixOS flake config";

  # ALWAYS use tag or specific commit for each input
  # Don't use inputs.<>.follows due to cache misses and issues. Only when absolutely necessary.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/b51242d7d43689db2f3be91bd05d5b24fbb469c4"; # branch nixos-26.05
    nixpkgs-unstable.url = "github:nixos/nixpkgs/64c08a7ca051951c8eae34e3e3cb1e202fe36786"; # branch nixos-unstable

    hyprland.url = "github:hyprwm/Hyprland/v0.55.2";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.55.0";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    inherit (inputs.self) outputs;

    forAllSystems = func:
      lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"] (
        # sys: func nixpkgs.legacyPackages.${sys}
        sys: (func (import nixpkgs {
          system = sys;
          config.allowUnfree = true;
        }))
      );
  in {
    # Formatter for your nix files, available through 'nix fmt'
    formatter = forAllSystems (pkgs: pkgs.alejandra);

    # Custom packages, to use through `nix build`, `nix shell`, etc.
    packages = forAllSystems (pkgs: import ./nix/pkgs {inherit pkgs;});

    # Flake templates
    templates.default = {
      description = "Default shell template";
      path = ./nix/shell_template;
    };

    # Package overlays
    overlays.default = import ./nix/overlays.nix {inherit inputs outputs lib;};

    # NixOS Modules
    nixosModules = import ./nix/modules {inherit lib;};

    # Configurations
    nixosConfigurations = {
      mahcomp = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
          username = "ivangeorgiew";
          graphicsCard = "nvidia";
        };
        modules =
          (builtins.attrValues outputs.nixosModules)
          ++ [./nix/modules/hardware_mahcomp.nix];
      };
    };
  };
}
