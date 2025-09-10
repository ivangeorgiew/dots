{inputs, ...}: final: prev: rec {
  # Prefer this method to legacyPackages in order to be able to use unfree packages
  unstable = import inputs.nixpkgs-unstable {
    system = prev.system;
    config.allowUnfree = true;
  };

  hland = {
    # nixpkgs-unstable which Hyprland uses. Can fix some issues.
    # No need for unfree packages for now
    nixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${prev.system};

    # Packages related to Hyprland
    hypr-pkgs = inputs.hyprland.packages.${prev.system};

    # Official Hyprland plugins by vaxry
    plugins-git = inputs.hyprland-plugins.packages.${prev.system};

    # Plugins from nixpkgs
    plugins-nix = unstable.hyprlandPlugins;

    # GUI for configuring Hyprland
    hyprviz = inputs.hyprviz.packages.${prev.system}.default;
  };

  custom = {
    # Discord client
    vesktop = prev.vesktop.override {withSystemVencord = false;};

    # Latest nvim version
    neovim-nightly = inputs.neovim-nightly.packages.${prev.system}.default;

    # Spotify without ads
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
          install -Dm644 config.toml -t $out/etc/spotify-adblock
          install -Dm644 --strip target/release/libspotifyadblock.so -t $out/lib
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
  };
}
