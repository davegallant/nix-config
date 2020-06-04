" nvim config

set nocompatible
filetype off

" disable swap files
set noswapfile

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'LnL7/vim-nix'
Plug 'ap/vim-css-color'
Plug 'fatih/vim-go'
Plug 'hashivim/vim-terraform'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'psf/black'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'vifm/vifm.vim'
Plug 'vim-syntastic/syntastic'
Plug 'yuki-ycino/fzf-preview.vim'
" Initialize plugin system
call plug#end()

filetype plugin indent on

" Security
set modelines=0

" Show line numbers
set number

" Show file stats
set ruler

" Highlight current line
set cursorline

" Encoding
set encoding=utf-8

" ignore case when searching
set ignorecase
set smartcase

" Status bar
set laststatus=2

" Last line
set showmode
set showcmd

" autoread
set autoread

" Mouse
set mouse=a

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Display all matching files when we tab complete
set wildmenu

set tabstop=2
set shiftwidth=2
set expandtab

" Enable folding
set foldmethod=indent
set foldlevel=99

" Incremental search
set incsearch

" highlight search
set hlsearch

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

set pastetoggle=<F3>

" Python indentation
au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix

let python_highlight_all=1

syntax on
set t_Co=256
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
