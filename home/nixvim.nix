{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    globals.clipboard = "osc52";

    opts = {
      backup = false;
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
      foldenable = false;
      foldexpr = "nvim_treesitter#foldexpr()";
      foldlevel = 20;
      foldmethod = "expr";
      ignorecase = true;
      modelines = 5;
      mouse = "a";
      number = true;
      scrolloff = 3;
      shell = "bash";
      shiftround = false;
      shiftwidth = 2;
      showbreak = "↳ ";
      sidescrolloff = 3;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      swapfile = false;
      switchbuf = "usetab";
      tabstop = 2;
      termguicolors = true;
    };

    autoGroups = {
      remember_cursor.clear = true;
    };

    autoCmd = [
      {
        event = "BufReadPost";
        group = "remember_cursor";
        command = ''if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif'';
      }
      {
        event = "BufEnter";
        command = "match ExtraWhitespace /\\s\\+$/";
      }
    ];

    highlight = {
      ExtraWhitespace = {
        ctermbg = "red";
        bg = "red";
      };
    };

    keymaps = [
      {
        key = "<C-n>";
        mode = [ "n" ];
        action = "<cmd>tabnew<cr>";
        options.silent = true;
      }
      {
        key = "<leader>y";
        mode = [ "v" ];
        action = ''"+y'';
      }
      {
        key = "<leader>t";
        mode = [ "n" ];
        action = "<cmd>NvimTreeFindFileToggle<CR>";
      }
      {
        key = "<leader>ff";
        mode = [ "n" ];
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        key = "<leader>fg";
        mode = [ "n" ];
        action = "<cmd>lua require('telescope').extensions['live_grep_args'].live_grep_args()<CR>";
      }
      {
        key = "<leader>s";
        mode = [ "n" ];
        action = "<cmd>lua require('spectre').open()<CR>";
      }
      {
        key = "<C-r>";
        mode = [ "v" ];
        action = ''"hy:%s/<C-r>h//g<left><left>'';
      }
    ];

    plugins = {
      auto-save.enable = true;
      cmp.enable = true;
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };
      gitlinker.enable = true;
      lualine.enable = true;
      lsp = {
        enable = true;
        servers = {
          bashls.enable = true;
          dockerls.enable = true;
          gopls.enable = true;
          helm_ls.enable = true;
          jsonls.enable = true;
          nixd.enable = true;
          terraformls.enable = true;
          yamlls.enable = true;
        };
      };
      lsp-format.enable = true;
      mini-icons = {
        enable = true;
        mockDevIcons = true;
      };
      nvim-tree.enable = true;
      spectre.enable = true;
      treesitter.enable = true;
      telescope = {
        enable = true;
        settings.defaults = {
          layout_strategy = "vertical";
          layout_config.vertical.width = 0.9;
        };
        extensions.fzy-native.enable = true;
        extensions.live-grep-args.enable = true;
      };
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
    '';
  };
}
