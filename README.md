# dotfiles

![screenshot](https://user-images.githubusercontent.com/4519234/77236166-52fe0d80-6b92-11ea-8b78-cb94b29c4265.png)

## use

```shell
git clone --bare git@github.com:davegallant/dotfiles.git $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # add alias to a .bashrc or .zshrc
source ~/.zshrc || source ~/.bashrc
config config --local status.showUntrackedFiles no
# override all config files
config checkout -f
```

See: https://www.atlassian.com/git/tutorials/dotfiles
