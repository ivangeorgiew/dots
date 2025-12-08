# Info: https://github.com/nix-community/nix-direnv
# Use: nix flake init -t github:ivangeorgiew/dots
{
  description = "Shell Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    inherit (inputs.self) outputs;

    forAllSystems = (
      func:
        lib.genAttrs ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"]
        (system:
          func (import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = builtins.attrValues outputs.overlays;
          }))
    );
  in {
    overlays = {
      modifications = finalPkgs: prevPkgs: rec {
        unstable = import inputs.nixpkgs-unstable {
          system = prevPkgs.system;
          config.allowUnfree = true;
        };

        modified = {
          # examples in my dots overlays.nix
        };
      };
    };

    devShells = forAllSystems (pkgs:
      with pkgs; {
        default = mkShell {
          name = "shell";

          # used at build-time
          nativeBuildInputs = [];

          # used at run-time
          buildInputs = [];

          # env variables
          NIX_CONFIG = "experimental-features = nix-command flakes";

          # init script
          shellHook = ''
            echo "Welcome to my nix-shell!" 1>/dev/null
          '';
        };
      });
  };
}
