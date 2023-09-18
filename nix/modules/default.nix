# Modules. All are included by default in the flake.nix file
{
  config = import ./config.nix;
  desktop = import ./desktop.nix; 
  packages = import ./packages.nix;
}
