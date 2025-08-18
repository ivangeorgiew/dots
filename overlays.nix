{inputs, ...}: final: prev: rec {
  # Prefer this method to legacyPackages in order to be able to use unfree packages
  unstable = import inputs.nixpkgs-unstable {
    system = prev.system;
    config.allowUnfree = true;
  };

  mpvpaper = prev.mpvpaper.overrideAttrs (oldAttrs: {
    src = prev.fetchFromGitHub {
      owner = "GhostNaN";
      repo = "mpvpaper";
      rev = "d8164bb6bd2960d2f7f6a9573e086d07d440f037";
      sha256 = "sha256-/A2C6T7gP+VGON3Peaz2Y4rNC63UT+zYr4RNM2gdLUY=";
    };
  });

  vesktop = prev.vesktop.override {withSystemVencord = false;};

  neovim = inputs.neovim-nightly.packages.${prev.system}.default;

  # https://github.com/NL-TCH/nur-packages/blob/master/pkgs/spotify-adblock/default.nix
  spotify-no-ads = let
    spotify-adblock = prev.rustPlatform.buildRustPackage {
      pname = "spotify-adblock";
      version = "1.0.3";
      src = prev.fetchFromGitHub {
        owner = "abba23";
        repo = "spotify-adblock";
        rev = "5a3281dee9f889afdeea7263558e7a715dcf5aab";
        hash = "sha256-UzpHAHpQx2MlmBNKm2turjeVmgp5zXKWm3nZbEo0mYE=";
      };
      cargoHash = "sha256-oGpe+kBf6kBboyx/YfbQBt1vvjtXd1n2pOH6FNcbF8M=";

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
    prev.spotify.overrideAttrs (oldAttrs:
      with prev; {
        buildInputs = (oldAttrs.buildInputs or []) ++ [zip unzip];
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
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
    postPatch =
      (oldAttrs.postPatch or "")
      + ''
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
}
