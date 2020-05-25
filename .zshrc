# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins=(fzf git zsh-syntax-highlighting last-working-dir)

# case-sensitive completion
CASE_SENSITIVE="true"

# Disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

HISTSIZE=1000000
SAVEHIST=1000000

source $ZSH/oh-my-zsh.sh

# Aliases
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias ll='exa -la'
alias grep='grep --color=auto --line-buffered'
alias vi='nvim'
alias vim='nvim'

export LANG=en_US.UTF-8
export EDITOR='vim'
export PATH=$PATH:$HOME/.local/bin
export GPG_TTY=$(tty)

setopt noincappendhistory

# golang
export GOPATH=$HOME/go

# fzf
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# rfd
eval "$(_RFD_COMPLETE=source_zsh rfd)"

# broot
source $HOME/.config/broot/launcher/bash/br

# zoxide
eval "$(zoxide init zsh)"

# starship
eval "$(starship init zsh)"
