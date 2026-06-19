# Dev shells
{lib, ...}:
builtins.listToAttrs
(builtins.map
  (name: {
    name = lib.strings.removeSuffix ".nix" "${name}";
    value = ./. + "/${name}";
  })
  (builtins.filter
    (name: name != "default.nix" && (lib.strings.hasSuffix ".nix" name))
    (builtins.attrNames (builtins.readDir ./.))))
