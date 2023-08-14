# Defines overlays
{ inputs, ... }:
{
  # Adds my custom packages from the 'pkgs' folder
  additions = final: _prev: import ./customPkgs { pkgs = final; }; 

  # Modifies existing pkgs https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
  {
    #example = prev.example.overrideAttrs (oldAttrs: rec { ... });
  };

  # Give access to unstable pkgs via `pkgs.unstable`
  unstable-packages = final: _prev:
  {
    unstable = import inputs.nixpkgs-unstable
    {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # Add NUR packages access via `pkgs.nur`
  nur-packages = inputs.nur.overlay;

  # External overlay example
  #neovim = neovim-nightly-overlay.overlays.default;
}
