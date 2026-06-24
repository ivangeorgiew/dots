{
  description = "Shell Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # nixos unstable branch
  };

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;

    forAllSystems = func:
      lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"] (
        sys: (func (import nixpkgs {
          system = sys;
          config.allowUnfree = true;
        }))
      );
  in {
    devShells = forAllSystems (pkgs: {
      # TODO: change the settings below
      default = pkgs.mkShell {
        name = "shell";

        # Env variables can be set here or in `shellHook`
        # NIX_CONFIG = "experimental-features = nix-command flakes";

        # Build dependencies
        inputsFrom = [];

        # Executables
        packages = [];

        # init script
        shellHook = ''
        '';
      };
    });
  };
}
