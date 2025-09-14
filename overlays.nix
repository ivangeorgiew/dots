{
  inputs,
  lib,
  nixpkgs-opts,
  ...
}: final: prev: rec {
  # Example to use a specific version of a package
  # some-old-pkg = (import (fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/0ad13a6833440b8e238947e47bea7f11071dc2b2.tar.gz";
  #   sha256 = "053ypqqcr3hbdh9c0fnzgs2cbwmi15vz9b1k33p4wk36f70w6il3";
  # }) nixpkgs-opts).some-old-pkg;

  # Prefer this method to legacyPackages in order to be able to use unfree packages
  unstable = import inputs.nixpkgs-unstable nixpkgs-opts;

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
    # neovim-nightly = inputs.neovim-nightly.packages.${prev.system}.default;

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
      old-spotify =
        (import (fetchTarball {
            url = "https://github.com/NixOS/nixpkgs/archive/84d4f874c2bac9f3118cb6907d7113b3318dcb5e.tar.gz";
            sha256 = "012bb8xa6jc1a6g1wgk2s3cbzd9pacc8p0b141sv3s23r5z254wm";
          })
          nixpkgs-opts).spotify;
    in
      old-spotify.overrideAttrs (oldAttrs:
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
