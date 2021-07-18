-- status line
require('lualine').setup()

-- lsp
require'lspconfig'.bashls.setup{}
require'lspconfig'.gopls.setup{}
require'lspconfig'.pyright.setup{}
require'lspconfig'.rls.setup{}
require'lspconfig'.rnix.setup{}
require'lspconfig'.solargraph.setup{}
require'lspconfig'.terraformls.setup{}
require'lspconfig'.tflint.setup{}
require'lspconfig'.yamlls.setup{}

-- treesitter
require('nvim-treesitter.configs').setup({
    ensure_installed = "all",

    highlight = {
        enable = true,
        custom_captures = {
            -- ["<capture group>"] = "<highlight group>",
            -- ["keyword"] = "TSString",
        },
    },

    indent = {
        enable = true
    },

    rainbow = {
      enable = true,
      extended_mode = true
    },
})


-- twilight
require("twilight").setup {
  dimming = {
    alpha = 0.50, -- amount of dimming
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
}

vim.api.nvim_exec([[
    set foldmethod=expr
    set foldlevel=20
    set nofoldenable
    set foldexpr=nvim_treesitter#foldexpr()
]], true)

