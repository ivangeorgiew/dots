let
  getAllPaths = (dirPath:
    let
      dirContents = builtins.readDir (./. + "${dirPath}");
      pathNames = builtins.attrNames dirContents;
    in
      foldl'
        (acc: path: 
          if (dirContents.${path} == "directory") then
            (acc ++ (builtins.map (x: "${path}/${x}") (getAllPaths "/${path}")))
          else
            (acc ++ [ path ])
        )
        []
        pathNames
  );
in
  builtins.listToAttrs
    (builtins.map
      (path: { name = "xdg.configFile.\"${path}\".text"; value = builtins.readFile (./. + "/${path}"); })
      (builtins.filter (name: name != "default.nix") (getAllPaths "")))
