# oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
plugins=(fzf git zsh-syntax-highlighting last-working-dir)

# case-sensitive completion
CASE_SENSITIVE="true"

# Aliases
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias grep='grep --color=auto --line-buffered'
alias vi='nvim'
alias vim='nvim'

# Disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

HISTSIZE=1000000
SAVEHIST=1000000

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export EDITOR='vim'
export PATH=$PATH:$HOME/.local/bin
export GPG_TTY=$(tty)

setopt noincappendhistory

# golang
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# rust
export PATH=$PATH:$HOME/.cargo/bin

# jvm
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$PATH:$HOME/.local/groovy-3.0.1/bin

# nodejs
export PATH=$PATH:$HOME/.local/node-v13.8.0-linux-x64/bin
export PATH=$HOME/.npm-global/bin:$PATH

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
