{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.username = "dgallant";
  home.homeDirectory = "/home/dgallant";

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "20.09";

  home.packages = with pkgs; [
    awscli2
    bat
    black
    chromium
    direnv
    exa
    fd
    fzf
    go
    google-cloud-sdk
    groovy
    hadolint
    htop
    jdk
    jq
    nmap
    openvpn
    python3
    ripgrep
    rustup
    signal-desktop
    slack
    spotify
    stalonetray
    terraform
    tflint
    tmux
    tree
    unzip
    vlc
    zathura
    zip
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    history.size = 1000000;

    localVariables = {
      COMPLETITION_WAITING_DOTS = "true";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#838383,underline";
    };

    initExtra = ''
      eval "$(direnv hook zsh)"
      eval "$(_RFD_COMPLETE=source_zsh rfd)"
      eval "$(starship init zsh)"

      export EDITOR='neovim'
      export GPG_TTY=$(tty)
      export GOPATH=$HOME/go
      source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';

    shellAliases = {
      ls   = "exa -la --git";
      ".." = "cd ..";
      config = "/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
      grep = "grep --color=auto --line-buffered";
    };

    "oh-my-zsh" = {
      enable = true;
      plugins = [
        "fzf"
        "git"
        "last-working-dir"
      ];
    };
  };

  programs.neovim =  {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      call plug#begin('~/.vim/plugged')
      Plug 'LnL7/vim-nix'
      Plug 'ap/vim-css-color'
      Plug 'fatih/vim-go'
      Plug 'hashivim/vim-terraform'
      Plug 'itchyny/lightline.vim'
      Plug 'junegunn/fzf'
      Plug 'junegunn/fzf.vim'
      Plug 'neoclide/coc.nvim', {'branch': 'release'}
      Plug 'rust-lang/rust.vim'
      Plug 'scrooloose/nerdtree'
      Plug 'tpope/vim-commentary'
      Plug 'tpope/vim-fugitive'
      Plug 'tpope/vim-surround'
      Plug 'vifm/vifm.vim'
      Plug 'vim-syntastic/syntastic'
      Plug 'yuki-ycino/fzf-preview.vim'
      call plug#end()

      set autoread
      set cursorline
      set encoding=utf-8
      set expandtab
      set foldlevel=99
      set foldmethod=indent
      set hlsearch
      set ignorecase
      set incsearch
      set laststatus=2
      set modelines=0
      set mouse=a
      set nocompatible
      set noswapfile
      set number
      set pastetoggle=<F3>
      set ruler
      set shiftwidth=2
      set showcmd
      set showmode
      set smartcase
      set t_Co=256
      set tabstop=2
      set wildmenu

      " Search down into subfolders
      " Provides tab-completion for all file-related tasks
      set path+=**

      filetype plugin indent on

      " Enable folding with the spacebar
      nnoremap <space> za

      " replace visually selected
      vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

      " Custom Commands
      command JsonFormat execute "::%!jq '.'"

      " Shortcuts
      map <Leader>r :Rg<CR>
      map <Leader>g :Rg<CR>
      map <Leader>f :FzfPreviewDirectoryFiles<CR>
      map <Leader>n :NERDTree<CR>

      noremap <Leader>y "*y
      noremap <Leader>p "*p
      noremap <Leader>Y "+y
      noremap <Leader>P "+p

      " Python indentation
      au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix

      let python_highlight_all=1

      syntax on
      colorscheme xoria256
      " Transparency
      hi Normal guibg=NONE ctermbg=NONE

      " highlight red lines
      highlight ExtraWhitespace ctermbg=red guibg=red
      match ExtraWhitespace /\s\+$/

      " groovy syntax
      au BufNewFile,BufRead *.groovy set tabstop=2 shiftwidth=2 expandtab
      au BufNewFile,BufRead Jenkinsfile setf groovy
      au BufNewFile,BufRead Jenkinsfile set tabstop=2 shiftwidth=2 expandtab

      " vim-go
      let g:go_auto_sameids = 0
      let g:go_fmt_command = "goimports"
      let g:go_fmt_experimental = 1
      let g:go_highlight_array_whitespace_error = 1
      let g:go_highlight_build_constraints = 1
      let g:go_highlight_chan_whitespace_error = 1
      let g:go_highlight_extra_types = 1
      let g:go_highlight_fields = 1
      let g:go_highlight_format_strings = 1
      let g:go_highlight_function_calls = 1
      let g:go_highlight_function_parameters = 1
      let g:go_highlight_functions = 1
      let g:go_highlight_generate_tags = 1
      let g:go_highlight_operators = 1
      let g:go_highlight_space_tab_error = 1
      let g:go_highlight_string_spellcheck = 1
      let g:go_highlight_trailing_whitespace_error = 0
      let g:go_highlight_types = 1
      let g:go_highlight_variable_assignments = 1
      let g:go_highlight_variable_declarations = 1
      let g:go_metalinter_autosave=1
      let g:go_metalinter_autosave_enabled=['golint', 'govet']
      let g:go_rename_command = 'gopls'

      " vim-terraform
      let g:terraform_align=1
      let g:terraform_fmt_on_save=1
      let g:terraform_fold_sections=1

      " rust.vim
      let g:rustfmt_autosave = 1

      " syntastic
      set statusline+=%#warningmsg#
      set statusline+=%{SyntasticStatuslineFlag()}
      set statusline+=%*

      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list = 1
      let g:syntastic_check_on_open = 1
      let g:syntastic_check_on_wq = 0
      '';
    };
}
