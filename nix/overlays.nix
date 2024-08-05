# Adds/modifies `pkgs` properties (Ex: adds `pkgs.nur`)
{ inputs, ... }:
{
  # Adds my custom packages from the 'pkgs' folder
  additions = final: _prev: { my-pkgs = import ./pkgs { pkgs = final; }; };

  # Modifies existing pkgs https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    mpvpaper = prev.mpvpaper.overrideAttrs (oldAttrs: {
      src = prev.fetchFromGitHub {
        owner = "GhostNaN";
        repo = "mpvpaper";
        rev = "d8164bb6bd2960d2f7f6a9573e086d07d440f037";
        sha256 = "sha256-/A2C6T7gP+VGON3Peaz2Y4rNC63UT+zYr4RNM2gdLUY=";
      };
    });

    vesktop = prev.vesktop.override { withSystemVencord = false; };

    neovim = inputs.neovim-nightly.packages.${prev.system}.default;

    freetube = prev.freetube.overrideAttrs (oldAttrs: rec {
      version = "0.21.3";
      src = prev.fetchurl {
        url = "https://github.com/FreeTubeApp/FreeTube/releases/download/v${version}-beta/freetube_${version}_amd64.AppImage";
        sha256 = "sha256-sg/ycFo4roOJ2sW4naRCE6dwGXVQFzF8uwAZQkS2EY4=";
      };
    });
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
}
