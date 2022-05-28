let
  nix-pre-commit-hooks =
    import (builtins.fetchTarball
    "https://github.com/cachix/pre-commit-hooks.nix/tarball/master");
in {
  pre-commit-check = nix-pre-commit-hooks.run {
    src = ./.;
    hooks = {
      shellcheck.enable = true;
      alejandra.enable = true;
    };
  };
}
