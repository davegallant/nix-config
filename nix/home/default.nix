{ pkgs, ... }:

{

  home = {
    sessionVariables = { EDITOR = "vim"; };
  };

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      enableSshSupport = true;
    };
  };

  fonts.fontconfig.enable = true;

  programs = {

    home-manager.enable = true;

    rtorrent = {
      enable = true;
      settings = ''
        directory.default.set = ~/Downloads/torrents
        pieces.hash.on_completion.set = yes
        schedule2 = watch_directory,5,5,load.start=~/Downloads/torrents/*.torrent
        session.path.set = ~/.rtorrent.session
      '';
    };

    git = {
      enable = true;

      userName = "Dave Gallant";

      aliases = {
        "aa" = "add -A .";
        "br" = "branch";
        "ca" = "commit -S --amend";
        "cb" = "checkout -b";
        "ci" = "commit";
        "cm" = "commit -m";
        "co" = "checkout";
        "cs" = "commit -S";
        "csm" = "commit -S -m";
        "csa" = "commit -S --amend";
        "deleted" = "log --diff-filter=D --summary";
        "di" = "diff";
        "dic" = "diff --cached";
        "dicn" = "diff --cached --name-only";
        "din" = "diff --name-only";
        "l" =
          "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        "ms" = "merge --squash";
        "pb" = "pull --rebase";
        "po" = "push origin";
        "por" = "push origin HEAD:refs/for/$1";
        "st" = "status";
        "wip" =
          "for-each-ref --sort='authordate:iso8601' --format=' %(color:green)%(authordate:relative)%09%(color:white)%(refname:short)' refs/heads";
      };

      includes = [{ path = "~/.gitconfig-work"; }];

      delta = {
        enable = true;

        options = {
          features = "line-numbers decorations";
          whitespace-error-style = "22 reverse";
          plus-style = "green bold ul '#198214'";
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            file-decoration-style = "none";
          };
        };
      };

      extraConfig = {
        push = { default = "current"; };
        pull = { rebase = true; };
      };

    };

    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;
        gcloud = { disabled = true; };
        scan_timeout = 10;
        character = { error_symbol = "[✖](bold red)"; };

        time = {
          time_format = "%T";
          format = "$time($style) ";
          style = "bright-white";
          disabled = false;
        };
      };
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      history.size = 1000000;

      localVariables = {
        CASE_SENSITIVE = "true";
        DISABLE_UNTRACKED_FILES_DIRTY = "true";
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#838383,underline";
        ZSH_DISABLE_COMPFIX = "true";
      };

      initExtra = ''
        export PATH=$PATH:~/.cargo/bin
        export PATH=$PATH:~/.local/bin
        export PATH=$PATH:~/.npm-packages/bin
        export PATH=$PATH:~/go/bin

        export LANG=en_US.UTF-8

        eval "$(direnv hook zsh)"
        eval "$(_RFD_COMPLETE=source_zsh rfd)"
        eval "$(jira --completion-script-zsh)"

        setopt noincappendhistory
        pfetch
      '';

      shellAliases = {
        ls = "exa -la --git";
        ".." = "cd ..";
        config = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
        grep = "grep --color=auto --line-buffered";
        k = "kubectl";
      };

      "oh-my-zsh" = {
        enable = true;
        plugins = [ "fzf" "git" "last-working-dir" ];
      };

      plugins = [{
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }];
    };

    alacritty = {
      enable = true;
      settings = {
        window.padding.x = 10;
        window.padding.y = 10;
        scrolling.history = 100000;
        live_config_reload = true;
        selection.save_to_clipboard = true;
        mouse.hide_when_typing = true;

        font = {
          normal.family = "Fira Code";
          size = 12;
        };

        shell = {
          program = "zsh";
          args = [ "-l" "-c" "tmux" "u" ];
        };

        colors = {
          primary.background = "0x101421";
          primary.foreground = "0xfffbf6";

          normal = {
            black = "0x2e2e2e";
            red = "0xeb4129";
            green = "0xabe047";
            yellow = "0xf6c744";
            blue = "0x47a0f3";
            magenta = "0x7b5cb0";
            cyan = "0x64dbed";
            white = "0xe5e9f0";
          };

          bright = {
            black = "0x565656";
            red = "0xec5357";
            green = "0xc0e17d";
            yellow = "0xf9da6a";
            blue = "0x49a4f8";
            magenta = "0xa47de9";
            cyan = "0x99faf2";
            white = "0xffffff";
          };

          key_bindings = [
            {
              key = "Home";
              mods = "Control";
              action = "ResetFontSize";
            }
            {
              key = "Plus";
              mods = "Control";
              action = "IncreaseFontSize";
            }
            {
              key = "Minus";
              mods = "Control";
              action = "DecreaseFontSize";
            }
          ];
        };
      };
    };

    go = {
      enable = true;
      goBin = "go/bin";
      goPath = "go";
    };

    tmux = {
      enable = true;
      clock24 = true;
      terminal = "screen-256color";
      customPaneNavigationAndResize = true;
      extraConfig = ''
        set-window-option -g automatic-rename on
        set-option -g set-titles on

        set -g mouse on

        # Length of tmux status line
        set -g status-left-length 30
        set -g status-right-length 150

        set -g status-interval 5

        set -g default-terminal "screen-256color" # colors!
        setw -g xterm-keys on

        set -g set-titles on          # set terminal title
        set -g display-panes-time 800 # slightly longer pane indicators display time
        set -g display-time 2000      # slightly longer status messages display time

        # Lots of scrollback.
        setw -g history-limit 50000000

        setw -q -g utf8 on

        # activity
        set -g monitor-activity on
        set -g visual-activity off

        set -g status-right '#(gitmux #{pane_current_path})'

        set -g @plugin 'tmux-plugins/tmux-pain-control'
        set -g @plugin 'tmux-plugins/tmux-sensible'
        set -g @plugin 'tmux-plugins/tmux-sessionist'
        set -g @plugin 'tmux-plugins/tmux-yank'
        set -g @plugin 'tmux-plugins/tpm'

        # Theme
        set -g @plugin 'seebi/tmux-colors-solarized'
        set -g @colors-solarized 'dark'

        # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
        run -b '~/.tmux/plugins/tpm/tpm'
      '';
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      extraConfig = ''
        call plug#begin('~/.vim/plugged')
        Plug 'LnL7/vim-nix'
        Plug 'airblade/vim-gitgutter'
        Plug 'ap/vim-css-color'
        Plug 'artur-shaik/vim-javacomplete2'
        Plug 'fatih/vim-go'
        Plug 'godlygeek/tabular'
        Plug 'hashivim/vim-terraform'
        Plug 'itchyny/lightline.vim'
        Plug 'junegunn/fzf'
        Plug 'junegunn/fzf.vim'
        Plug 'leafgarland/typescript-vim'
        Plug 'neoclide/coc.nvim', {'branch': 'release'}
        Plug 'peitalin/vim-jsx-typescript'
        Plug 'plasticboy/vim-markdown'
        Plug 'rust-lang/rust.vim'
        Plug 'scrooloose/nerdtree'
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-fugitive'
        Plug 'tpope/vim-repeat'
        Plug 'tpope/vim-surround'
        Plug 'vifm/vifm.vim'
        Plug 'vim-syntastic/syntastic'
        Plug 'prettier/vim-prettier', {
          \ 'do': 'yarn install',
          \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }
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
        set number relativenumber
        set pastetoggle=<F3>
        set ruler
        set shiftwidth=2
        set showcmd
        set showmode
        set smartcase
        set t_Co=256
        set tabstop=2
        set wildmenu

        " Remember line number
        au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

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
        map <Leader>f :Files<CR>
        map <Leader>g :GFiles<CR>
        map <Leader>n :NERDTreeToggle<CR>
        map <C-s> :tabn<CR>
        map <C-a> :tabp<CR>
        map <C-n> :tabnew<CR>

        " Copypasta
        noremap <Leader>y "+y
        noremap <Leader>p "+p

        " yaml indentation
        au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

        " Python indentation
        au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix
        let python_highlight_all=1
        syntax on
        colorscheme gruvbox

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

        " fzf.vim
        let g:fzf_preview_window = 'right:60%'
        let g:fzf_layout = { 'window': 'enew' }

        " vim-markdown
        let g:vim_markdown_override_foldtext=0
        let g:vim_markdown_no_default_key_mappings=1
        let g:vim_markdown_emphasis_multiline=0
        let g:vim_markdown_conceal=0
        let g:vim_markdown_frontmatter=1
        let g:vim_markdown_new_list_item_indent=0

        " vim-javacomplete2
        autocmd FileType java setlocal omnifunc=javacomplete#Complete
      '';
    };
  };
}
