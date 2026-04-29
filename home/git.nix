{ ... }:
{
  programs = {
    diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user.name = "Dave Gallant";
        user.signingkey = "5A548984C7377E4D";
        commit.gpgsign = true;
        tag.gpgsign = true;
        alias = {
          aa = "add -A .";
          br = "branch";
          c = "commit";
          cm = "commit -m";
          ca = "commit --amend";
          cane = "commit --amend --no-edit";
          cb = "checkout -b";
          cmp = "! git checkout main && git pl";
          co = "checkout";
          d = "diff";
          dc = "diff --cached";
          dcn = "diff --cached --name-only";
          l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          ms = "merge --squash";
          p = "push origin";
          pl = "! git pull origin $(git rev-parse --abbrev-ref HEAD)";
          pom = "pull origin main";
          st = "status";
          wip = "for-each-ref --sort='authordate:iso8601' --format=' %(color:green)%(authordate:relative)%09%(color:white)%(refname:short)' refs/heads";
        };
        push = {
          default = "current";
        };
        pull = {
          rebase = true;
        };
      };

      includes = [ { path = "~/.gitconfig-work"; } ];

    };
  };
}
