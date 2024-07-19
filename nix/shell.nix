# You can enter the shell with `nix develop`
{ pkgs ? (import ./nixpkgs.nix) {} }: {
  default = pkgs.mkShell {
    name = "dots";
    packages = with pkgs; [ nix git ];

    # env variables
    NIX_CONFIG = "experimental-features = nix-command flakes";

    # init script
    shellHook = ''
      echo "Welcome to my nix-shell!"
    '';
  };
}
