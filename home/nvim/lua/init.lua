-----------------------------------------------------------------------------
-- Options {{{1 ---------------------------------------------------------------
-------------------------------------------------------------------------------
vim.opt.autoindent = true
vim.opt.backup = false
vim.opt.belloff = "all"
vim.opt.completeopt = "menuone"
vim.opt.completeopt = vim.opt.completeopt + "noselect"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.fillchars = {
	diff = "∙",
	eob = " ",
	vert = "┃",
}
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.modelines = 5
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.scrolloff = 3
vim.opt.shell = "bash"
vim.opt.shiftround = false
vim.opt.shiftwidth = 2
vim.opt.shortmess = vim.opt.shortmess + "A"
vim.opt.shortmess = vim.opt.shortmess + "I"
vim.opt.shortmess = vim.opt.shortmess + "O"
vim.opt.shortmess = vim.opt.shortmess + "T"
vim.opt.shortmess = vim.opt.shortmess + "W"
vim.opt.shortmess = vim.opt.shortmess + "a"
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.opt.shortmess = vim.opt.shortmess + "o"
vim.opt.shortmess = vim.opt.shortmess + "t"
vim.opt.showbreak = "↳ "
vim.opt.showcmd = true
vim.opt.sidescroll = 0
vim.opt.sidescrolloff = 3
vim.opt.smartcase = true
vim.opt.smarttab = true
vim.opt.spellcapcheck = ""
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.switchbuf = "usetab"
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.wildmenu = true

-- Format JSON
vim.cmd([[command! JsonFormat execute "::%!jq '.'"]])

-- Tab shortcuts
vim.api.nvim_set_keymap("n", "<C-n>", "<cmd>tabnew<cr>", { noremap = true })

-- Copy to OS clipboard
vim.api.nvim_set_keymap("v", "<leader>y", '"+y', { noremap = true })

-- Folding
vim.api.nvim_set_keymap("n", "<space>", "za", { silent = true, noremap = true })

-- Map gx to xdg-open
vim.api.nvim_set_keymap(
	"n",
	"gx",
	":execute 'silent! !xdg-open ' . shellescape(expand('<cWORD>'), 1)<cr>",
	{ silent = true, noremap = true }
)

-- Use tab as trigger keys
vim.cmd([[imap <tab> <Plug>(completion_smart_tab)]])
vim.cmd([[imap <s-tab> <Plug>(completion_smart_s_tab)]])

-- Remember line number
vim.cmd([[au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif]])

-- Replace visual selection
vim.cmd([[vnoremap <C-r> "hy:%s/<C-r>h//g<left><left>]])

-- Indent YAML
vim.cmd([[au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab]])

-- Indent Python
vim.cmd([[au BufNewFile,BufRead *.py set tabstop=4 softtabstop=4 shiftwidth=4 textwidth=79 expandtab autoindent fileformat=unix]])

-- Highlight whitespace
vim.cmd([[highlight ExtraWhitespace ctermbg=red guibg=red]])
vim.cmd([[match ExtraWhitespace /\s\+$/]])

-------------------------------------------------------------------------------
-- LSP {{{1 -------------------------------------------------------------------
-------------------------------------------------------------------------------
-- See `:help vim.lsp.*` for documentation on any of the below functions

local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
vim.api.nvim_set_keymap("n", "<space>", "za", { silent = true, noremap = true })

require("lspconfig").bashls.setup({})
require("lspconfig").gopls.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").rls.setup({})
require("lspconfig").rnix.setup({})
require("lspconfig").solargraph.setup({})
require("lspconfig").terraformls.setup({})
require("lspconfig").tflint.setup({})
require("lspconfig").yamlls.setup({})

vim.cmd([[autocmd BufWritePre *.tf lua vim.lsp.buf.formatting_sync()]])
vim.cmd([[autocmd BufWritePre *.py lua vim.lsp.buf.formatting_sync()]])
vim.cmd([[autocmd BufWritePre *.go lua vim.lsp.buf.formatting_sync()]])
vim.cmd([[autocmd BufWritePre *.rb lua vim.lsp.buf.formatting_sync()]])
vim.cmd([[autocmd BufWritePre *.nix lua vim.lsp.buf.formatting_sync()]])

-------------------------------------------------------------------------------
-- packer {{{1 -------------------------------------------------------------------
-------------------------------------------------------------------------------
require("packer").startup(function()
	use({ "ms-jpq/coq_nvim", branch = "coq" }) -- main one
	use({ "ms-jpq/coq.artifacts", branch = "artifacts" }) -- 9000+ Snippets
end)

-------------------------------------------------------------------------------
-- Plugins {{{1 ---------------------------------------------------------------
-------------------------------------------------------------------------------
-- gitlinker
require("gitlinker").setup()

-- status line
require("lualine").setup({
	options = {
		theme = "gruvbox",
	},
})

-- nvim-tree
require'nvim-tree'.setup {}

-- gitsigns
require('gitsigns').setup()

-- treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = "all",

	highlight = {
		enable = true,
	},

	indent = {
		enable = true,
	},

	rainbow = {
		enable = true,
		extended_mode = true,
	},
})

-- folding
vim.api.nvim_exec(
	[[
    set foldmethod=expr
    set foldlevel=20
    set nofoldenable
    set foldexpr=nvim_treesitter#foldexpr()
]],
	true
)

-- vim-markdown
vim.g.vim_markdown_override_foldtext = 0
vim.g.vim_markdown_no_default_key_mappings = 1
vim.g.vim_markdown_emphasis_multiline = 0
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_frontmatter = 1
vim.g.vim_markdown_new_list_item_indent = 0

-- vim-prettier
vim.g["prettier#autoformat"] = 1

-- git-blame
vim.g.gitblame_enabled = 0

vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files find_command=rg,--ignore,--hidden,--files,-g,!.git prompt_prefix=🔍<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true, noremap = true })

-- NvimTree
vim.api.nvim_set_keymap("n", "<leader>n", "<cmd>NvimTreeToggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>r", "<cmd>NvimTreeRefresh<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>nf", "<cmd>NvimTreeFindFile<cr>", { noremap = true })

-- completion-nvim
vim.cmd([[autocmd BufEnter * lua require'completion'.on_attach()]])

--Set colorscheme
vim.o.termguicolors = true
vim.cmd([[colorscheme gruvbox]])
