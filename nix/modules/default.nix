# Modules. All are included by default in the flake.nix file
# auto adds all files to a attrSet. Ex. for file "bla": `{ bla = import ./bla.nix }`
{ lib }:
builtins.listToAttrs
  (builtins.map
    (file: { name = (lib.strings.removeSuffix ".nix" "${file}"); value = import (./. + "/${file}"); })
    (builtins.filter
      (file: file != "default.nix")
      (builtins.attrNames (builtins.readDir ./.))))
