{ inputs, outputs, lib, config, pkgs, username, ... }:
{
  # Setup fonts
  fonts = {
    # Enables common fonts
    enableDefaultPackages = true;

    # Create dir with all fonts for compatibility
    fontDir.enable = true;

    fontconfig = {
      enable = true;

      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Noto Sans Mono" ];
        emoji = [ "Symbols Nerd Font" "Twitter Color Emoji" "Noto Color Emoji" ];
      };
    };

    # Font packages
    packages = with pkgs; [
      # Nerd Fonts with icons
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" "Iosevka" "FiraCode" "JetBrainsMono" "SourceCodePro" ]; })
      #(nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })

      dejavu_fonts
      noto-fonts
      noto-fonts-emoji
      twitter-color-emoji
      #fira-code
      #fira-code-symbols
      #iosevka
      #source-code-pro
    ];
  };
}
