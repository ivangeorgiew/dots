{ inputs, outputs, username, lib, config, pkgs, ... }:
let
appSettings = {
  # Let home-manager install and manage itself
  home-manager.enable = true;

  # Interactive shell
  fish = {
    enable = true;

    useBabelfish = true; # Bash to Fish translation

    interactiveShellInit = ''
      #Disable greeting
      set fish_greeting
    '';

    loginShellInit =
    let
      dquote = str: "\"" + str + "\"";
      makeBinPathList = map (path: path + "/bin");
    in ''
      # Fix for/from https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
      fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
      set fish_user_paths $fish_user_paths
    '';
  };

  # IDE/Text editor
  neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
};
in
{
  # required for home-manager to work
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # global home-manager settings
  home-manager = {
    useGlobalPackages = true;
    useUserPackages = false;
    extraSpecialArgs = { inherit inputs outputs username; };

    users."${username}" = _: {
      # Add my dot files
      imports = [ ../../homeDots ];

      # Basic info
      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "23.05"; # Don't change

        # add local executables to PATH
        sessionPath = [ "$HOME/.local/bin" ];
      }; 

      nixpkgs = {
        # Set the same overlays as for the nixos config
        overlays = outputs.overlays;

        config = {
          # Fix for https://github.com/nix-community/home-manager/issues/2942
          allowUnfreePredicate = _: true;
          allowUnfree = true;
        };
      };

      # reload systemd units when config changes
      systemd.user.startServices = "sd-switch";

      # Defined at the top of the file
      programs = appSettings;
    };
  };
}
