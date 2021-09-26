-----------------------------------------------------------------------------
-- Options {{{1 ---------------------------------------------------------------
-------------------------------------------------------------------------------
vim.opt.autoindent = true -- maintain indent of current line
vim.opt.backup = false -- don't make backups before writing
vim.opt.belloff = "all" -- never ring the bell for any reason
vim.opt.breakindent = true
vim.opt.completeopt = "menuone" -- show menu even if there is only one candidate (for nvim-compe)
vim.opt.completeopt = vim.opt.completeopt + "noselect" -- don't automatically select canditate (for nvim-compe)
vim.opt.cursorline = true -- highlight current line
vim.opt.expandtab = true -- always use spaces instead of tabs
vim.opt.fillchars = {
	diff = "∙", -- BULLET OPERATOR (U+2219, UTF-8: E2 88 99)
	eob = " ", -- NO-BREAK SPACE (U+00A0, UTF-8: C2 A0) to suppress ~ at EndOfBuffer
	vert = "┃", -- BOX DRAWINGS HEAVY VERTICAL (U+2503, UTF-8: E2 94 83)
}
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.mouse = "a" -- enable mouse
vim.opt.shiftwidth = 2
vim.opt.showcmd = true
vim.opt.smartcase = true
vim.opt.tabstop = 2
vim.opt.wildmenu = true

vim.opt.modelines = 5 -- scan this many lines looking for modeline
vim.opt.number = true -- show line numbers in gutter
vim.opt.pumblend = 10 -- pseudo-transparency for popup-menu
vim.opt.relativenumber = true -- show relative numbers in gutter
vim.opt.scrolloff = 3 -- start scrolling 3 lines before edge of viewport

vim.opt.spellcapcheck = "" -- don't check for capital letters at start of sentence
vim.opt.splitbelow = true -- open horizontal splits below current window
vim.opt.splitright = true -- open vertical splits to the right of the current window
vim.opt.suffixes = vim.opt.suffixes - ".h" -- don't sort header files at lower priority
vim.opt.swapfile = false -- don't create swap files
vim.opt.switchbuf = "usetab" -- try to reuse windows/tabs when switching buffers
vim.opt.synmaxcol = 200 -- don't bother syntax highlighting long lines
vim.opt.tabstop = 2 -- spaces per tab
vim.opt.termguicolors = true -- use guifg/guibg instead of ctermfg/ctermbg in terminal

vim.opt.shell = "bash" -- shell to use for `!`, `:!`, `system()` etc.
vim.opt.shiftround = false -- don't always indent by multiple of shiftwidth
vim.opt.shiftwidth = 2 -- spaces per tab (when shifting)
vim.opt.shortmess = vim.opt.shortmess + "A" -- ignore annoying swapfile messages
vim.opt.shortmess = vim.opt.shortmess + "I" -- no splash screen
vim.opt.shortmess = vim.opt.shortmess + "O" -- file-read message overwrites previous
vim.opt.shortmess = vim.opt.shortmess + "T" -- truncate non-file messages in middle
vim.opt.shortmess = vim.opt.shortmess + "W" -- don't echo "[w]"/"[written]" when writing
vim.opt.shortmess = vim.opt.shortmess + "a" -- use abbreviations in messages eg. `[RO]` instead of `[readonly]`
vim.opt.shortmess = vim.opt.shortmess + "c" -- completion messages
vim.opt.shortmess = vim.opt.shortmess + "o" -- overwrite file-written messages
vim.opt.shortmess = vim.opt.shortmess + "t" -- truncate file messages at start
vim.opt.showbreak = "↳ " -- DOWNWARDS ARROW WITH TIP RIGHTWARDS (U+21B3, UTF-8: E2 86 B3)
vim.opt.showcmd = false -- don't show extra info at end of command line
vim.opt.sidescroll = 0 -- sidescroll in jumps because terminals are slow
vim.opt.sidescrolloff = 3 -- same as scrolloff, but for columns
vim.opt.smarttab = true -- <tab>/<BS> indent/dedent in leading whitespace

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

--Set colorscheme
vim.o.termguicolors = true
vim.cmd([[colorscheme gruvbox]])

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
require("lspconfig").bashls.setup({})
require("lspconfig").gopls.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").rls.setup({})
require("lspconfig").rnix.setup({})
require("lspconfig").solargraph.setup({})
require("lspconfig").terraformls.setup({})
require("lspconfig").tflint.setup({})
require("lspconfig").yamlls.setup({})

-------------------------------------------------------------------------------
-- packer {{{1 -------------------------------------------------------------------
-------------------------------------------------------------------------------
require("packer").startup(function()
	use({ "ms-jpq/coq_nvim", branch = "coq" }) -- main one
	use({ "ms-jpq/coq.artifacts", branch = "artifacts" }) -- 9000+ Snippets
	use({
		"AckslD/nvim-neoclip.lua",
		config = function()
			require("neoclip").setup()
		end,
	})
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

-- treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = "all",

	highlight = {
		enable = true,
		custom_captures = {
			-- ["<capture group>"] = "<highlight group>",
			-- ["keyword"] = "TSString",
		},
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

-- trouble
require("trouble").setup({
	{
		position = "bottom", -- position of the list can be: bottom, top, left, right
		height = 10, -- height of the trouble list when position is top or bottom
		width = 50, -- width of the list when position is left or right
		icons = true, -- use devicons for filenames
		mode = "lsp_workspace_diagnostics", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
		fold_open = "", -- icon used for open folds
		fold_closed = "", -- icon used for closed folds
		action_keys = { -- key mappings for actions in the trouble list
			close = "q", -- close the list
			cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
			refresh = "r", -- manually refresh
			jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
			open_split = { "<c-x>" }, -- open buffer in new split
			open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
			open_tab = { "<c-t>" }, -- open buffer in new tab
			jump_close = { "o" }, -- jump to the diagnostic and close the list
			toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
			toggle_preview = "P", -- toggle auto_preview
			hover = "K", -- opens a small popup with the full multiline message
			preview = "p", -- preview the diagnostic location
			close_folds = { "zM", "zm" }, -- close all folds
			open_folds = { "zR", "zr" }, -- open all folds
			toggle_fold = { "zA", "za" }, -- toggle fold of current file
			previous = "k", -- preview item
			next = "j", -- next item
		},
		indent_lines = true, -- add an indent guide below the fold icons
		auto_open = false, -- automatically open the list when you have diagnostics
		auto_close = false, -- automatically close the list when you have no diagnostics
		auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
		auto_fold = false, -- automatically fold a file trouble list at creation
		signs = {
			-- icons / text used for a diagnostic
			error = "",
			warning = "",
			hint = "",
			information = "",
			other = "﫠",
		},
		use_lsp_diagnostic_signs = false, -- enabling this will use the signs defined in your lsp client
	},
})
vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>Trouble<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>xw",
	"<cmd>Trouble lsp_workspace_diagnostics<cr>",
	{ silent = true, noremap = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<leader>xd",
	"<cmd>Trouble lsp_document_diagnostics<cr>",
	{ silent = true, noremap = true }
)
vim.api.nvim_set_keymap("n", "<leader>xl", "<cmd>Trouble loclist<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>xq", "<cmd>Trouble quickfix<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "gR", "<cmd>Trouble lsp_references<cr>", { silent = true, noremap = true })

-- twilight
require("twilight").setup({
	dimming = {
		alpha = 0.25, -- amount of dimming
		-- we try to get the foreground from the highlight groups or fallback color
		color = { "Normal", "#cccccc" },
	},
	context = 10, -- amount of lines we will try to show around the current line
	expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
		"function",
		"method",
		"table",
		"if_statement",
	},
	exclude = {}, -- exclude these filetypes
})

-- hound.nvim
require("hound").setup({
	hound_base_url = "http://hound", -- Rely on Tailscale's MagicDNS
	hound_port = 6080, -- the port hound is running on
	search_results_buffer = "tabnew", -- how to open the search results (vsplit, split, tabnew)
	display_file_match_urls = true, -- whether or not urls should be displayed alongside file matches
	hound_url_pattern = "https://github.com/{repo}/blob/{revision}/{path}", -- the format of the url displayed for file matches
})
vim.api.nvim_set_keymap("n", "<leader>hs", ":Hound", { silent = true, noremap = true })

-- neoclip
require('telescope').load_extension('neoclip')


-- vim-go
vim.g.go_auto_sameids = 0
vim.g.go_fmt_command = "goimports"
vim.g.go_fmt_experimental = 1
vim.g.go_highlight_array_whitespace_error = 1
vim.g.go_highlight_build_constraints = 1
vim.g.go_highlight_chan_whitespace_error = 1
vim.g.go_highlight_extra_types = 1
vim.g.go_highlight_fields = 1
vim.g.go_highlight_format_strings = 1
vim.g.go_highlight_function_calls = 1
vim.g.go_highlight_function_parameters = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_generate_tags = 1
vim.g.go_highlight_operators = 1
vim.g.go_highlight_space_tab_error = 1
vim.g.go_highlight_string_spellcheck = 1
vim.g.go_highlight_trailing_whitespace_error = 0
vim.g.go_highlight_types = 1
vim.g.go_highlight_variable_assignments = 1
vim.g.go_highlight_variable_declarations = 1
vim.g.go_rename_command = "gopls"
vim.g.go_metalinter_autosave = 1
vim.g.go_metalinter_autosave_enabled = { "golint", "govet" }

-- vim-terraform
vim.g.terraform_align = 1
vim.g.terraform_fmt_on_save = 1
vim.g.terraform_fold_sections = 1

-- rust.vim
vim.g.rustfmt_autosave = 1

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

-- telescope
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true, noremap = true })

-- NvimTree
vim.api.nvim_set_keymap("n", "<leader>n", "<cmd>NvimTreeToggle<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>r", "<cmd>NvimTreeRefresh<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>nf", "<cmd>NvimTreeFindFile<cr>", { noremap = true })

-- syntastic
vim.g.syntastic_always_populate_loc_list = 1
vim.g.syntastic_auto_loc_list = 1
vim.g.syntastic_check_on_open = 1
vim.g.syntastic_check_on_wq = 0

-- completion-nvim
vim.cmd([[autocmd BufEnter * lua require'completion'.on_attach()]])
