# Initially based on https://github.com/Misterio77/nix-starter-configs/tree/main/standard
{
  description = "My NixOS flake config";

  # ALWAYS use tag or specific commit for each input
  # Don't use inputs.<>.follows due to cache misses and issues. Only when absolutely necessary.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/b51242d7d43689db2f3be91bd05d5b24fbb469c4"; # branch nixos-26.05
    nixpkgs-unstable.url = "github:nixos/nixpkgs/64c08a7ca051951c8eae34e3e3cb1e202fe36786"; # branch nixos-unstable

    hyprland.url = "github:hyprwm/Hyprland/v0.54.3";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/b85a56b9531013c79f2f3846fd6ee2ff014b8960"; # TODO: change to tag when added
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
    packages.${system} = import ./nix/pkgs {inherit pkgs;};

    # Flake templates
    templates.default = {
      description = "Default shell template";
      path = ./nix/shell_template;
    };

    # Package overlays
    overlays.default = import ./nix/overlays.nix {inherit inputs outputs lib system nixpkgs-opts;};

    # NixOS Modules
    nixosModules = import ./nix/modules {inherit lib;};

    # Configurations
    nixosConfigurations = {
      mahcomp = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs outputs nixpkgs-opts;
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
