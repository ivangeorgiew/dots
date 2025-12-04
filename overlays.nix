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

  # Unstable wrapper, not unstable neovim
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/editors/neovim/wrapper.nix
  wrapNeovimUnstable = unstable.wrapNeovimUnstable.override {
    # Overrides python3 packages to fix pynvim version `:checkhealth` warning
    python3 = unstable.python312;
  };

  custom = {
    # Discord client
    vesktop = prev.vesktop.override {withSystemVencord = false;};

    # Latest nvim version
    # neovim-nightly = inputs.neovim-nightly.packages.${prev.system}.default;

    # Use my fork of lua_ls until the bugfix is merged: https://github.com/LuaLS/lua-language-server/pull/3307
    lua_ls = prev.lua-language-server.overrideAttrs (oldAttrs:
      with prev; {
        version = "3.16.0";
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ (with pkgs; [libunwind libbfd_2_38]);
        src = fetchFromGitHub {
          owner = "ivangeorgiew";
          repo = "lua-language-server";
          rev = "4ff491cbac27";
          hash = "sha256-p34Uqgg74y6wmztyECaYayFTmSzrR9c9TS4w0t8uocg=";
          fetchSubmodules = true;
        };
      });

    viber = prev.viber.overrideAttrs (oldAttrs:
      with prev; {
        installPhase =
          (oldAttrs.installPhase or "")
          + ''
            # Revert change
            substituteInPlace $out/share/applications/viber.desktop \
              --replace $out/opt/viber/ /opt/viber/

            # Apply it correctly
            substituteInPlace $out/share/applications/viber.desktop \
              --replace /opt/viber/ $out/opt/viber/
          '';
      });

    # Spotify without ads
    # https://github.com/NL-TCH/nur-packages/blob/master/pkgs/spotify-adblock/default.nix
    spotify-no-ads = let
      spotify-adblock = prev.rustPlatform.buildRustPackage {
        pname = "spotify-adblock";
        version = "lastcommit at 2025-05-20";
        src = prev.fetchFromGitHub {
          owner = "abba23";
          repo = "spotify-adblock";
          rev = "refs/heads/main";
          fetchSubmodules = false;
          hash = "sha256-nwiX2wCZBKRTNPhmrurWQWISQdxgomdNwcIKG2kSQsE=";
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
      # NOTE: Careful for the following issues
      # 1. memory leaks
      # 2. music search not working
      spotify =
        (import (fetchTarball {
            url = "https://github.com/NixOS/nixpkgs/archive/e8f40168fbd024866f22e2c8d18fe040e3691022.tar.gz";
            sha256 = "18fhkp37rm3mld6m1j6a4jknl3j3rgwpyqrqy3arbj9x7bzy5gkz";
          })
          nixpkgs-opts).spotify;
    in
      spotify.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ (with prev; [zip unzip]);
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
