# Info: https://github.com/nix-community/nix-direnv
# Use: nix flake init -t github:ivangeorgiew/dots
{
  description = "Shell Flake";

  inputs = {
    # TODO: change to specific commit hash
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # nixos unstable branch
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    inherit (inputs.self) outputs;

    forAllSystems = func:
      lib.genAttrs ["x86_64-linux" "aarch64-linux" "aarch64-darwin"] (
        sys: (func (import nixpkgs {
          system = sys;
          config.allowUnfree = true;
          overlays = [outputs.overlays.default];
        }))
      );
  in {
    # Example in https://github.com/ivangeorgiew/dots/blob/master/nix/overlays.nix
    overlays.default = final: prev: {};

    devShells = forAllSystems (pkgs:
      with pkgs; {
        # TODO: configure the settings below
        default = mkShell {
          name = "shell";

          # Build dependencies
          inputsFrom = [];

          # Executables
          packages = [hello];

          # Env variables can be set here or in `shellHook`
          NIX_CONFIG = "experimental-features = nix-command flakes";

          # init script
          shellHook = ''
            hello
          '';
        };
      });
  };
}
