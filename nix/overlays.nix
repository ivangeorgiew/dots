# Adds/modifies `pkgs` properties (Ex: adds `pkgs.nur`, modifies `pkgs.hyprland`)
{ inputs, ... }:
{
  # Adds my custom packages from the 'pkgs' folder
  additions = final: _prev: import ./pkgs { pkgs = final; }; 

  # Modifies existing pkgs https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    #example = prev.example.overrideAttrs (oldAttrs: rec { ... });
  };

  # Adds `pkgs.unstable`
  unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # NUR packages https://github.com/nix-community/NUR/blob/master/flake.nix
  nur = inputs.nur.overlay;

  # Hyprland packages https://github.com/hyprwm/Hyprland/blob/main/nix/overlays.nix
  #hyprland = inputs.hyprland.overlays.default;

  # Hyprland own implementation of XDG-desktop-portal https://github.com/hyprwm/xdg-desktop-portal-hyprland/blob/master/nix/overlays.nix
  #xdg-desktop-portal-hyprland = inputs.xdg-desktop-portal-hyprland.overlays.default;

  # Neovim nightly https://github.com/nix-community/neovim-nightly-overlay
  #neovim = inputs.neovim-nightly-overlay.overlay;
}
