# Custom packages. Can be built using `nix build .#example`
{ pkgs ? (import ../nixpkgs.nix), inputs ? {} }:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  #example = pkgs.callPackage ./example { };
}
