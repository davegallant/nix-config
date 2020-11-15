# dotfiles

## Setup a bare git repo

```shell
git clone --bare git@github.com:davegallant/dotfiles.git $HOME/.dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # add alias to a .bashrc or .zshrc
source ~/.zshrc || source ~/.bashrc
config config --local status.showUntrackedFiles no
# override all config files
config checkout -f
```
