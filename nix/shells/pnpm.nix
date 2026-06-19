{
  pkgs,
  unstable,
  ...
}:
pkgs.mkShell {
  name = "pnpm";

  # Build dependencies
  inputsFrom = [];

  # Executables
  packages = [
    unstable.nodejs_26
    (unstable.pnpm.override {
      version = "11.8.0";
      hash = "sha256-HpY6XEylFoVQugP8TujYc6dysHK3/OY7SP/yfXIOLpg=";
    })
  ];

  # Env variables can be set here or in `shellHook`
  NIX_CONFIG = "experimental-features = nix-command flakes";

  # Init script
  shellHook = ''
    pnpm i
  '';
}
