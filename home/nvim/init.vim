set autoread
set cursorline
set encoding=utf-8
set expandtab
set foldlevel=99
set foldmethod=indent
set hlsearch
set ignorecase
set incsearch
set mouse=a
set nocompatible
set number relativenumber
set pastetoggle=<F3>
set shiftwidth=2
set showcmd
set smartcase
set t_Co=256
set tabstop=2
set wildmenu

" Disable swp and swo files
set noswapfile

" Remember line number
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

filetype plugin indent on

" Enable folding with the spacebar
nnoremap <space> za

" Replace visually selected
vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>

" Custom Commands
command! JsonFormat execute "::%!jq '.'"

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

" Indent YAML
au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Python indentation
au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix
let python_highlight_all=1
syntax on
colorscheme gruvbox

" Highlight whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Groovy syntax
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
let g:go_rename_command = 'gopls'
let g:go_metalinter_autosave=1
let g:go_metalinter_autosave_enabled=['golint', 'govet']

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

" telescope-nvim
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" vim-markdown
let g:vim_markdown_override_foldtext=0
let g:vim_markdown_no_default_key_mappings=1
let g:vim_markdown_emphasis_multiline=0
let g:vim_markdown_conceal=0
let g:vim_markdown_frontmatter=1
let g:vim_markdown_new_list_item_indent=0

" vim-javacomplete2
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" vim-prettier
let g:prettier#autoformat = 1

lua << EOF
require('lualine').setup()

require'lspconfig'.bashls.setup{}
require'lspconfig'.gopls.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.rls.setup{}
require'lspconfig'.rnix.setup{}
require'lspconfig'.terraformls.setup{}
require'lspconfig'.tflint.setup{}
require'lspconfig'.yamlls.setup{}
EOF

