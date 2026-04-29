{ ... }:

{
  home.file.".local/bin/gh-clone" = {
    executable = true;
    source = ./gh-clone.sh;
  };

  home.file.".config/nvim/lua/gh-clone.lua" = {
    source = ./gh-clone.lua;
  };

}
