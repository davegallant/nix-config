# dotfiles

![screenshot](https://user-images.githubusercontent.com/4519234/89136156-34286400-d500-11ea-838c-59ced8eff5ea.png)

## use

```shell
git clone --bare git@github.com:davegallant/dotfiles.git $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # add alias to a .bashrc or .zshrc
source ~/.zshrc || source ~/.bashrc
config config --local status.showUntrackedFiles no
# override all config files
config checkout -f
```
