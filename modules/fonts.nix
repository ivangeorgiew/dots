{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  # Setup fonts
  fonts = {
    # Enables common fonts, causes more issues than it solves
    enableDefaultPackages = false;

    # Create dir with all fonts for compatibility
    fontDir.enable = true;

    fontconfig = {
      enable = true;

      # Noto Color Emoji everywhere to overwrite DejaVu's B&W emojis
      defaultFonts = {
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Noto Sans" "Noto Color Emoji"];
        monospace = ["Noto Sans Mono" "Noto Color Emoji"];
        emoji = ["Symbols Nerd Font" "Twitter Color Emoji" "Noto Color Emoji"];
      };
    };

    # Font packages
    packages = with pkgs; [
      # Nerd Fonts with icons
      nerd-fonts.symbols-only
      nerd-fonts.iosevka
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono

      dejavu_fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      twitter-color-emoji
    ];
  };
}
