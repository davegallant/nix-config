_:

{
  home.file.".local/bin/gh-clone" = {
    executable = true;
    source = ./gh-clone.sh;
  };

  home.file.".local/bin/clone-org" = {
    source = ./clone-org.sh;
    executable = true;
  };

  home.file.".config/nvim/lua/gh-clone.lua" = {
    source = ./gh-clone.lua;
  };
}
