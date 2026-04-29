{ ... }:

{
  home.file.".local/bin/clone-org" = {
    source = ./clone-org.sh;
    executable = true;
  };
}
