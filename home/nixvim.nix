{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    keymaps = [
      {
        key = "<C-n>";
        mode = [ "n" ];
        action = "<cmd>tabnew<cr>";
        options = {
          silent = true;
        };
      }
      {
        key = "<leader>y";
        mode = [ "v" ];
        action = ''"+y''; # copy to OS clipboard
      }
      {
        key = "<leader>t";
        mode = [ "n" ];
        action = "<cmd>NvimTreeFindFileToggle<CR>";
      }
      {
        key = "gD";
        mode = [ "n" ];
        action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      }
      {
        key = "gd";
        mode = [ "n" ];
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      }
      {
        key = "gr";
        mode = [ "n" ];
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
      }
      {
        key = "<leader>ff";
        mode = [ "n" ];
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        key = "<leader>fg";
        mode = [ "n" ];
        action = "<cmd>Telescope live_grep<CR>";
      }
    ];

    plugins = {
      auto-save.enable = true;
      cmp-path.enable = true;
      cmp-treesitter.enable = true;
      commentary.enable = true;
      diffview.enable = true;
      gitblame.enable = true;
      gitsigns.enable = true;
      gitlinker.enable = true;
      lualine.enable = true;
      lsp.enable = true;
      lsp.servers = {
        bashls.enable = true;
        dockerls.enable = true;
        gopls.enable = true;
        helm_ls.enable = true;
        jsonls.enable = true;
        nixd.enable = true;
        terraformls.enable = true;
        yamlls.enable = true;
      };
      lsp-format = {
        enable = true;
        settings = {
          terraform = { };
          nix = { };
          go = { };
        };
      };
      cmp.enable = true;
      nvim-tree.enable = true;
      rainbow-delimiters.enable = true;
      treesitter.enable = true;
      telescope = {
        enable = true;
        settings.defaults = {
          layout_strategy = "vertical";
          layout_config = {
            vertical = {
              width = 0.9;
            };
          };
        };
        package = pkgs.vimPlugins.telescope-fzy-native-nvim;
      };
      web-devicons.enable = true;
    };
    globals.clipboard = "osc52";
    opts = {
      autoindent = true;
      backup = false;
      belloff = "all";
      completeopt = [
        "menuone"
        "noselect"
      ];
      cursorline = true;
      expandtab = true;
      fillchars = {
        diff = "∙";
        eob = " ";
        vert = "┃";
      };
      hlsearch = true;
      ignorecase = true;
      incsearch = true;
      modelines = 5;
      mouse = "a";
      number = true;
      pumblend = 10;
      scrolloff = 3;
      shell = "bash";
      shiftround = false;
      shiftwidth = 2;
      showbreak = "↳ ";
      showcmd = true;
      sidescroll = 0;
      sidescrolloff = 3;
      smartcase = true;
      smarttab = true;
      spellcapcheck = "";
      splitbelow = true;
      splitright = true;
      swapfile = false;
      switchbuf = "usetab";
      tabstop = 2;
      termguicolors = true;
      wildmenu = true;
    };

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "ghostty-default-style-dark-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "nkxxll";
          repo = "ghostty-default-style-dark.nvim";
          rev = "master";
          sha256 = "sha256-Qxj2f8f1lS/kAxpWNVz/cjYCvO9WSamgj6mrgDdvziM=";
        };
        doCheck = false;
      })
    ];

    extraConfigLua = ''

        vim.cmd.colorscheme("ghostty-default-style-dark")

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


      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
    '';
  };
}
