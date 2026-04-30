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
      {
        event = "OptionSet";
        pattern = "diff";
        callback = {
          __raw = ''
            function()
              if vim.o.diff then
                vim.opt_local.wrap = true
              end
            end
          '';
        };
      }
      {
        event = "User";
        pattern = "PersistenceSavePre";
        callback = {
          __raw = ''
            function()
              local view = require("nvim-tree.view")
              if view.is_visible() then
                vim.cmd("NvimTreeClose")
              end
            end
          '';
        };
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
        key = "<leader>tc";
        mode = [ "n" ];
        action = "<cmd>tabclose<cr>";
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
        action = "<cmd>Git<CR>";
        options = {
          silent = true;
          desc = "Git status";
        };
      }
      {
        key = "<leader>gc";
        mode = [ "n" ];
        action = "<cmd>Git commit<CR>";
        options = {
          silent = true;
          desc = "Git commit";
        };
      }
      {
        key = "<leader>gp";
        mode = [ "n" ];
        action = "<cmd>Git pull<CR>";
        options = {
          silent = true;
          desc = "Git pull";
        };
      }
      {
        key = "<leader>gP";
        mode = [ "n" ];
        action = "<cmd>Git push<CR>";
        options = {
          silent = true;
          desc = "Git push";
        };
      }
      {
        key = "<leader>gd";
        mode = [ "n" ];
        action = "<cmd>Git diff<CR>";
        options = {
          silent = true;
          desc = "Git diff";
        };
      }
      {
        key = "<leader>gdc";
        mode = [ "n" ];
        action = "<cmd>Git diff --cached<CR>";
        options = {
          silent = true;
          desc = "Git diff (staged)";
        };
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
      {
        key = "<leader>op";
        action.__raw = ''function() vim.cmd("Octo pr list") end'';
        options.desc = "List PRs";
      }
      {
        key = "<leader>od";
        action.__raw = ''function() vim.cmd("Octo pr diff") end'';
        options.desc = "Show the PR diff";
      }
      {
        key = "<leader>or";
        action.__raw = ''function() vim.cmd("Octo review start") end'';
        options.desc = "Start a review";
      }
      {
        key = "<leader>ou";
        action.__raw = ''function() vim.cmd("Octo pr url") end'';
        options.desc = "Show and copy the PR url";
      }
      {
        key = "<leader>os";
        action.__raw = ''function() vim.cmd("Octo review submit") end'';
        options.desc = "Submit a review";
      }
      {
        mode = "n";
        key = "<leader>sp";
        action = "<cmd>Telescope project<CR>";
        options = {
          desc = "Switch project";
          silent = true;
        };
      }
      {
        mode = "n";
        key = "<leader>qs";
        action.__raw = ''function() require("persistence").load() end'';
        options.desc = "Restore session for CWD";
      }
      {
        mode = "n";
        key = "<leader>qS";
        action.__raw = ''function() require("persistence").select() end'';
        options.desc = "Select session";
      }
      {
        mode = "n";
        key = "<leader>ql";
        action.__raw = ''function() require("persistence").load({ last = true }) end'';
        options.desc = "Restore last session";
      }
      {
        key = "K";
        mode = [ "n" ];
        action.__raw = ''function() vim.lsp.buf.hover() end'';
        options = {
          silent = true;
          desc = "LSP hover";
        };
      }
      {
        key = "<leader>ca";
        mode = [ "n" "v" ];
        action.__raw = ''function() vim.lsp.buf.code_action() end'';
        options = {
          silent = true;
          desc = "Code action";
        };
      }
      {
        key = "<leader>rn";
        mode = [ "n" ];
        action.__raw = ''function() vim.lsp.buf.rename() end'';
        options = {
          silent = true;
          desc = "Rename symbol";
        };
      }
      {
        key = "[d";
        mode = [ "n" ];
        action.__raw = ''function() vim.diagnostic.goto_prev() end'';
        options = {
          silent = true;
          desc = "Previous diagnostic";
        };
      }
      {
        key = "]d";
        mode = [ "n" ];
        action.__raw = ''function() vim.diagnostic.goto_next() end'';
        options = {
          silent = true;
          desc = "Next diagnostic";
        };
      }
      {
        key = "<leader>fb";
        mode = [ "n" ];
        action = "<cmd>Telescope buffers<CR>";
        options = {
          silent = true;
          desc = "Find buffers";
        };
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
      fugitive.enable = true;
      octo.enable = true;
      nvim-tree.enable = true;
      persistence = {
        enable = true;
        settings.excluded_filetypes = [ "NvimTree" ];
      };
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
        enabledExtensions = [ "project" ];

        settings.extensions.project = {
          base_dirs.__raw = ''
            (function()
              local f = io.open(vim.fn.expand("~/.config/cd-fzf"), "r")
              if not f then return {} end
              local dirs = {}
              for line in f:lines() do
                line = line:match("^%s*(.-)%s*$")  -- trim whitespace
                if line ~= "" then
                  table.insert(dirs, { path = line, max_depth = 1 })
                end
              end
              f:close()
              return dirs
            end)()
          '';
          hidden_files = true;
          theme = "dropdown";
          order_by = "recent";
          search_by = "title";
        };

      };
    };

    extraPlugins = [
      pkgs.vimPlugins.telescope-project-nvim
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
      require("gh-clone")
      vim.cmd.colorscheme("ghostty-default-style-dark")
    '';
  };
}
