# Custom packages. Can be built using `nix build .#example`
{pkgs, ...}: {
  #example = pkgs.callPackage ./example.nix { };
}
