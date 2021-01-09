# config

This repo stores nix, dotfiles, and other miscellaneous scripts.

## Setup

Clone this as a bare repo to avoid the need for symlinking:

```console
$ git clone --bare git@github.com:davegallant/config.git $HOME/.dotfiles
$ alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME' # add alias to a .bashrc or .zshrc
$ source ~/.zshrc
$ config config --local status.showUntrackedFiles no
$ config checkout -f # this will overwrite any existing configs in the home directory
```
