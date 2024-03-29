# You can enter the shell with `nix develop`
{ pkgs ? (import ./nixpkgs.nix) {} }: {
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [ nix git ];
  }
}
