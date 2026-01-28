{
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [ just ];

  services = {
    gpg-agent = {
      enable = stdenv.isLinux;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      enableSshSupport = true;
    };
  };

  services.lorri.enable = stdenv.isLinux;

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    direnv.enable = true;

    diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;

      lfs.enable = true;

      settings = {
        user.name = "Dave Gallant";
        user.signingkey = "5A548984C7377E4D";
        commit.gpgsign = true;
        tag.gpgsign = true;
        alias = {
          aa = "add -A .";
          br = "branch";
          c = "commit";
          cm = "commit -m";
          ca = "commit --amend";
          cane = "commit --amend --no-edit";
          cb = "checkout -b";
          cmp = "! git checkout main && git pl";
          co = "checkout";
          d = "diff";
          dc = "diff --cached";
          dcn = "diff --cached --name-only";
          l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          ms = "merge --squash";
          p = "push origin";
          pf = "push -f";
          pl = "! git pull origin $(git rev-parse --abbrev-ref HEAD)";
          pom = "pull origin main";
          st = "status";
          wip = "for-each-ref --sort='authordate:iso8601' --format=' %(color:green)%(authordate:relative)%09%(color:white)%(refname:short)' refs/heads";
        };
        push = {
          default = "current";
        };
        pull = {
          rebase = true;
        };
      };

      includes = [ { path = "~/.gitconfig-work"; } ];

    };

    alacritty = {
      enable = stdenv.isLinux;
      settings = {
        window.padding.x = 10;
        window.padding.y = 10;
        scrolling.history = 100000;
        general.live_config_reload = true;
        terminal.shell = {
          program = "fish";
        };
        font = {
          size = lib.mkForce 14.0;
        };
        window = {
          opacity = lib.mkForce 0.9;
        };
      };
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        gcloud = {
          format = "";
        };
        kubernetes = {
          disabled = false;
        };
      };
    };

    fish = {
      enable = true;

      interactiveShellInit = ''
          set fish_greeting

          bind \cw backward-kill-word

          set -x DOCKER_CLI_HINTS false
          set -x DOCKER_DEFAULT_PLATFORM linux/amd64
          set -x EDITOR vim
          set -x NNN_FIFO "$XDG_RUNTIME_DIR/nnn.fifo"
          set -x PAGER less
          set -x TERM xterm-256color

          set -x PATH $PATH \
            ~/.cargo/bin \
            ~/.local/bin \
            ~/.npm-packages/bin \
            /opt/homebrew/bin \
            ~/.krew/bin \
            ~/bin

          # golang
          set -x GOPATH ~/go
          set -x GOBIN $GOPATH/bin
          set -x PATH $PATH $GOBIN

          source $HOME/work.fish
        # '';

      shellInit = ''
        atuin init fish | source
        helm completion fish | source
        kubectl completion fish | source
      '';

      shellAliases = {
        ".." = "cd ..";
        g = "git";
        gc = "git checkout $(git branch | fzf)";
        gco = "git checkout $(git branch -r | sed -e 's/^  origin\\///' | fzf)";
        gho = "gh repo view --web >/dev/null";
        gr = "cd $(git rev-parse --show-toplevel)";
        grep = "rg --smart-case";
        j = "just";
        k = "kubecolor";
        kubectl = "kubecolor";
        kp = "viddy 'kubectl get pods'";
        kcx = "kubectx";
        kns = "kubens";
        l = "eza -la --git --group-directories-first";
        m = "make";
        nix-install = "nix-env -iA";
        t = "cd-fzf";
        tf = "terraform";
        tree = "eza --tree";
        v = "nvim";
        zed = "zeditor";
      };
    };

    go = {
      enable = true;
    };

    fzf = {
      enable = true;
    };

    nnn = {
      enable = stdenv.isLinux;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
      bookmarks = {
        d = "~/Downloads";
        p = "~/src/";
        c = "~/.config";
        h = "~";
      };
      extraPackages = with pkgs; [
        bat
        eza
        fzf
        imv
        mediainfo
        ffmpegthumbnailer
      ];
      plugins = {
        src = "${pkgs.nnn.src}/plugins";
        mappings = {
          p = "preview-tui";
          o = "fzopen";
        };
      };
    };

    nixvim = {
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

      extraConfigLua = ''

        -- https://github.com/orgs/community/discussions/108329
        vim.cmd([[let g:copilot_filetypes = {'yaml': v:true}]])

        vim.cmd([[let g:copilot_filetypes = {'gitcommit': v:true}]])

        -- Format JSON
        vim.cmd([[command! JsonFormat execute "::%!jq '.'"]])

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
      '';
    };

    mangohud = {
      enable = stdenv.isLinux;
      settings = {
        font_size = 16;
        position = "top-right";
        toggle_hud = "Shift_R+F1";
      };
    };

    zed-editor = {
      enable = stdenv.isLinux;
      package = unstable.zed-editor;
      extensions = [
        "ansible"
        "color-highlight"
        "dockerfile"
        "html"
        "make"
        "material-icon-theme"
        "nix"
        "toml"
        "vue"
      ];
      userSettings = {
        icon_theme = "Material Icon Theme";
        features = {
          edit_prediction_provider = "copilot";
        };
        vim_mode = true;
        vim = {
          use_system_clipboard = "on_yank";
        };
        autosave = "on_focus_change";
        format_on_save = "off";
        ui_font_size = lib.mkForce 18;
        buffer_font_size = lib.mkForce 16;
      };
      userKeymaps = [
        {
          context = "Editor && !menu";
          bindings = {
            "ctrl-shift-c" = "editor::Copy";
            "ctrl-shift-x" = "editor::Cut";
            "ctrl-shift-v" = "editor::Paste";
            "ctrl-z" = "editor::Undo";
          };
        }
      ];
    };

    firefox = {
      enable = stdenv.isLinux;

      package = pkgs.librewolf;

      profiles = {
        default = {
          id = 0;
          isDefault = true;
          settings = {
            "privacy.resistFingerprinting" = false; # breaks timezone
            "dom.push.connection.enabled" = false;
            "dom.push.enabled" = false;
            "geo.enabled" = false;
            "intl.regional_prefs.use_os_locales" = true;
            "services.sync.prefs.sync.intl.regional._prefs.use_os_locates" = false;
          };
        };
      };
    };
  };
}
