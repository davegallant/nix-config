{ pkgs, ... }:
{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    globals.clipboard = "osc52";

    opts = {
      completeopt = [
        "menuone"
        "noselect"
      ];
      cursorline = true;
      expandtab = true;
      foldenable = false;
      foldexpr = "nvim_treesitter#foldexpr()";
      foldlevel = 20;
      foldmethod = "expr";
      ignorecase = true;
      mouse = "a";
      number = true;
      shell = "bash";
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
        key = "gd";
        mode = [ "n" ];
        action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      }
      {
        key = "gD";
        mode = [ "n" ];
        action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      }
      {
        key = "gr";
        mode = [ "n" ];
        action = "<cmd>lua vim.lsp.buf.references()<CR>";
      }
      {
        key = "<leader>ff";
        mode = [ "n" ];
        action = "<cmd>Telescope find_files hidden=true find_command=rg,--files,--hidden,--glob,!**/.git/**<CR>";

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
      {
        key = "<leader>g";
        mode = [ "n" ];
        action = "<cmd>Neogit<CR>";
        options.silent = true;
      }
      {
        key = "<leader>d";
        mode = [ "n" ];
        action = "<cmd>DiffviewOpen<CR>";
        options.silent = true;
      }
      {
        key = "<leader>gb";
        action.__raw = ''
          function()
            vim.system({"git", "fetch", "--prune"}, {})
            require("telescope.builtin").git_branches({
              attach_mappings = function(_, map)
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                actions.select_default:replace(function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)
                  local branch = selection.value:gsub("^origin/", "")
                  vim.fn.system("git switch " .. branch)
                end)
                return true
              end
            })
          end
        '';
        options.desc = "Git branches (fetch first)";
      }
    ];

    plugins = {
      auto-save.enable = true;
      cmp.enable = true;
      gitsigns = {
        enable = true;
        settings.current_line_blame = true;
      };
      diffview.enable = true;
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
      neogit = {
        enable = true;
        settings.integrations.diffview = true;
      };
      octo.enable = true;
      nvim-tree.enable = true;
      spectre.enable = true;
      treesitter.enable = true;
      telescope = {
        enable = true;
        settings.defaults = {
          layout_strategy = "vertical";
          layout_config.vertical.width = 0.9;
          vimgrep_arguments = [
            "rg"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
            "--hidden"
            "--glob"
            "!**/.git/**"
          ];
        };
        extensions.fzf-native.enable = true;
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
