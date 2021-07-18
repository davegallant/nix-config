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

vim.api.nvim_exec([[
    set foldmethod=expr
    set foldlevel=20
    set nofoldenable
    set foldexpr=nvim_treesitter#foldexpr()
]], true)

