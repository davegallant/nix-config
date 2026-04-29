{ ... }:

{
  home.file.".local/bin/nix-search" = {
    source = ./nix-search.sh;
    executable = true;
  };

  home.file.".local/bin/clone-org" = {
    source = ./clone-org.sh;
    executable = true;
  };
}
