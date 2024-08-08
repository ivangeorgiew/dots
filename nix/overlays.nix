{ inputs, ... }:
{
  # Adds my custom packages from the 'pkgs' folder
  additions = finalPkgs: _prevPkgs: { my-pkgs = import ./pkgs { pkgs = finalPkgs; }; };

  # Modifies existing pkgs https://nixos.wiki/wiki/Overlays
  modifications = finalPkgs: prevPkgs: rec {
    # Adds `pkgs.unstable`
    unstable = import inputs.nixpkgs-unstable {
      system = finalPkgs.system;
      config.allowUnfree = true;
    };

    modified = {
      mpvpaper = prevPkgs.mpvpaper.overrideAttrs (oldAttrs: {
        src = prevPkgs.fetchFromGitHub {
          owner = "GhostNaN";
          repo = "mpvpaper";
          rev = "d8164bb6bd2960d2f7f6a9573e086d07d440f037";
          sha256 = "sha256-/A2C6T7gP+VGON3Peaz2Y4rNC63UT+zYr4RNM2gdLUY=";
        };
      });

      vesktop = prevPkgs.vesktop.override { withSystemVencord = false; };

      neovim = inputs.neovim-nightly.packages.${prevPkgs.system}.default;

      freetube = prevPkgs.freetube.overrideAttrs (oldAttrs: rec {
        version = "0.21.3";
        src = prevPkgs.fetchurl {
          url = "https://github.com/FreeTubeApp/FreeTube/releases/download/v${version}-beta/freetube_${version}_amd64.AppImage";
          sha256 = "sha256-sg/ycFo4roOJ2sW4naRCE6dwGXVQFzF8uwAZQkS2EY4=";
        };
      });

      # https://github.com/NL-TCH/nur-packages/blob/master/pkgs/spotify-adblock/default.nix
      spotify-no-ads =
      let
        spotify-adblock = prevPkgs.rustPlatform.buildRustPackage {
          pname = "spotify-adblock";
          version = "1.0.3";
          src = prevPkgs.fetchFromGitHub {
            owner = "abba23";
            repo = "spotify-adblock";
            rev = "5a3281dee9f889afdeea7263558e7a715dcf5aab";
            hash = "sha256-UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
          };
          cargoSha256 = "sha256-wPV+ZY34OMbBrjmhvwjljbwmcUiPdWNHFU3ac7aVbIQ=";

          patchPhase = ''
            substituteInPlace src/lib.rs \
              --replace 'config.toml' $out/etc/spotify-adblock/config.toml
          '';

          buildPhase = ''
            make
          '';

          installPhase = ''
            mkdir -p $out/etc/spotify-adblock
            install -D --mode=644 config.toml $out/etc/spotify-adblock
            mkdir -p $out/lib
            install -D --mode=644 --strip target/release/libspotifyadblock.so $out/lib
          '';
        };
      in
        prevPkgs.spotify.overrideAttrs (oldAttrs: with prevPkgs; {
          buildInputs = (oldAttrs.buildInputs or []) ++ [ zip unzip ];
          postInstall = (oldAttrs.postInstall or "") + ''
            ln -s ${spotify-adblock}/lib/libspotifyadblock.so $libdir
            wrapProgram $out/bin/spotify \
              --set LD_PRELOAD "${spotify-adblock}/lib/libspotifyadblock.so"

            # Hide placeholder for advert banner
            unzip -p $out/share/spotify/Apps/xpui.spa xpui.js | sed 's/adsEnabled:\!0/adsEnabled:false/' > $out/share/spotify/Apps/xpui.js
            zip --junk-paths --update $out/share/spotify/Apps/xpui.spa $out/share/spotify/Apps/xpui.js
            rm $out/share/spotify/Apps/xpui.js
          '';
        });

      nwg-hello = unstable.nwg-hello.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace nwg_hello/main.py \
            --replace "$out/etc/nwg-hello/nwg-hello.json" "/etc/nwg-hello/nwg-hello.json" \
            --replace "$out/etc/nwg-hello/nwg-hello.css" "/etc/nwg-hello/nwg-hello.css"

          substituteInPlace nwg-hello-default.css \
            --replace "/usr/share/nwg-hello/nwg.jpg" "$out/share/nwg-hello/nwg.jpg"
        '';
      });

      nwg-dock-hyprland = unstable.nwg-dock-hyprland.overrideAttrs (oldAttrs: {
        src = unstable.fetchFromGitHub {
          owner = "ivangeorgiew";
          repo = "nwg-dock-hyprland";
          rev = "8b9d78d2ae0c0d090d1f5838c299f12c44958b73";
          hash = "sha256-6+3sdG7rARcBGTHa/WUxSMnatZh4TYLSzhxz40XLBaA=";
        };
      });
    };
  };
}
