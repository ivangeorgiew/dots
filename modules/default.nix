# Modules. All are included by default in the flake.nix file
# auto adds all files to a attrSet. Ex. for file "bla": `{ bla = import ./bla.nix }`
{lib}:
builtins.listToAttrs
(builtins.map
  (name: {
    name = lib.strings.removeSuffix ".nix" "${name}";
    value = import (./. + "/${name}");
  })
  (builtins.filter
    (name: name != "default.nix" && !(lib.strings.hasPrefix "hardware" name))
    (builtins.attrNames (builtins.readDir ./.))))
