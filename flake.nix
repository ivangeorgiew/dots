# Initially based on https://github.com/Misterio77/nix-starter-configs/tree/main/standard
{
  description = "My NixOS flake config";

  # Use specific commits for repos without versioned tags so flake.lock can be deleted if there are issues.
  # Don't use inputs.<>.follows due to cache misses and issues. Only when absolutely necessary.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/b4c2c57c31e68544982226d07e4719a2d86302a8"; # branch nixos-25.05

    nixpkgs-unstable.url = "github:nixos/nixpkgs/d7600c775f877cd87b4f5a831c28aa94137377aa"; # branch nixos-unstable

    hyprland.url = "github:hyprwm/Hyprland/v0.50.1";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.50.0";
      inputs.hyprland.follows = "hyprland";
    };

    hyprviz = {
      url = "github:timasoft/hyprviz/ec9ef8fe3f13537c1cfdd5c88ce0b900a1ed04ac";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    # Probably don't need unfree packages here
    # but if you do -> (import nixpkgs nixpkgs-opts)
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
    #   path = ./shell_template;
    # };

    # Package overlays
    overlays.default = import ./overlays.nix {inherit inputs lib nixpkgs-opts;};

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
