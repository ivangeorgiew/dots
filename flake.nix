# Initially based on https://github.com/Misterio77/nix-starter-configs/tree/main/standard
{
  description = "My NixOS flake config";

  # ALWAYS use tag or specific commit for each input
  # Don't use inputs.<>.follows due to cache misses and issues. Only when absolutely necessary.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/b4c2c57c31e68544982226d07e4719a2d86302a8"; # branch nixos-25.05
    nixpkgs-unstable.url = "github:nixos/nixpkgs/0147c2f1d54b30b5dd6d4a8c8542e8d7edf93b5d"; # branch nixos-unstable

    hyprland.url = "github:hyprwm/Hyprland/v0.51.0";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.51.0";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    inherit (self) outputs;
    inherit (nixpkgs) lib;

    system = "x86_64-linux";
    nixpkgs-opts = {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = nixpkgs.legacyPackages.${system};

    forAllSystems = func:
      lib.genAttrs ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"] (
        sys: func nixpkgs.legacyPackages.${sys}
        # sys: func (import nixpkgs (nixpkgs-opts // {system = sys;}))
      );
  in {
    # Formatter for your nix files, available through 'nix fmt'
    formatter.${system} = pkgs.alejandra;

    # Custom packages, to use through `nix build`, `nix shell`, etc.
    packages.${system} = import ./pkgs {inherit pkgs;};

    # Flake templates
    # templates.default = {
    #   description = "Default shell template";
    #   path = ./shell_template;
    # };

    # Package overlays
    overlays.default = import ./overlays.nix {inherit inputs outputs lib system nixpkgs-opts;};

    # NixOS Modules
    nixosModules = import ./modules {inherit lib;};

    # Configurations
    nixosConfigurations = {
      mahcomp = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs outputs nixpkgs-opts;
          username = "ivangeorgiew";
          graphicsCard = "nvidia";
        };
        modules = (builtins.attrValues outputs.nixosModules) ++ [./modules/hardware_mahcomp.nix];
      };
    };
  };
}
