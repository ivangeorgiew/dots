# Custom packages. Can be built using `nix build .#example`
{ pkgs ? (import ../nixpkgs.nix) }:
{
  #example = pkgs.callPackage ./example { };
}
