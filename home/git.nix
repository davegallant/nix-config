_: {
  programs = {
    git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user.name = "Dave Gallant";
        user.signingkey = "5A548984C7377E4D";
        commit.gpgsign = true;
        tag.gpgsign = true;
        alias = {
          c = "commit";
          cm = "commit -m";
          ca = "commit --amend";
          cane = "commit --amend --no-edit";
          cb = "checkout -b";
          cmp = "! git checkout main && git pl";
          co = "checkout";
          p = "push origin";
          pl = "! git pull origin $(git rev-parse --abbrev-ref HEAD)";
          pom = "pull origin main";
        };
        push = {
          default = "current";
        };
        pull = {
          rebase = true;
        };
      };

      includes = [ { path = "~/.config/git/config-work"; } ];

    };
  };
}
