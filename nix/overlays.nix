# Adds/modifies `pkgs` properties (Ex: adds `pkgs.nur`)
{ inputs, ... }:
{
  # Adds my custom packages from the 'pkgs' folder
  additions = final: _prev: import ./pkgs { pkgs = final; }; 

  # Modifies existing pkgs https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    #example = prev.example.overrideAttrs (oldAttrs: rec { ... });

    #replaces the default package
    neovim = inputs.neovim-nightly.packages.${prev.system}.neovim;
  };

  # Adds `pkgs.stable`
  stable = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # NUR packages https://github.com/nix-community/NUR/blob/master/flake.nix
  nur = inputs.nur.overlay;
}
