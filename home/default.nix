{
  lib,
  pkgs,
  ...
}: let
  hound-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "hound-nvim";
    nativeBuildInputs = with pkgs; [lua53Packages.luacheck stylua];
    src = pkgs.fetchFromGitHub {
      owner = "davegallant";
      repo = "hound.nvim";
      rev = "e85ba4f65ece79fe6332d8a0ccc594a0d367f4ed";
      sha256 = "sha256-fxPtixVB6dVjrxpJ1oP+eA00JSiKxWuii8pMxVeuyMY=";
    };
  };
  inherit (pkgs) stdenv;
in {
  home.stateVersion = "22.11";

  services = {
    gpg-agent = {
      enable = stdenv.isLinux;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      enableSshSupport = true;
    };
    opensnitch-ui.enable = stdenv.isLinux;
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    direnv.enable = true;

    git = {
      enable = true;

      userName = "Dave Gallant";

      lfs.enable = true;

      aliases = {
        aa = "add -A .";
        br = "branch";
        c = "commit -S";
        ca = "commit -S --amend";
        cane = "commit -S --amend --no-edit";
        cb = "checkout -b";
        co = "checkout";
        cmp = "! git checkout main && git pl";
        d = "diff";
        dc = "diff --cached";
        dcn = "diff --cached --name-only";
        ds = "! git diff origin | sed -r 's/value: (.*)/value: \"************\"/'";
        l = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        ms = "merge --squash";
        p = "push origin";
        pf = "push -f";
        pl = "! git pull origin $(git rev-parse --abbrev-ref HEAD)";
        st = "status";
        wip = "for-each-ref --sort='authordate:iso8601' --format=' %(color:green)%(authordate:relative)%09%(color:white)%(refname:short)' refs/heads";
      };

      includes = [{path = "~/.gitconfig-work";}];

      delta = {
        enable = true;

        options = {
          features = "line-numbers decorations";
          whitespace-error-style = "22 reverse";
          plus-style = "green bold ul '#198214'";
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            file-decoration-style = "none";
          };
        };
      };

      extraConfig = {
        push = {default = "current";};
        pull = {rebase = true;};
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;
        scan_timeout = 10;
        character = {error_symbol = "[✖](bold red)";};
        gcloud = {
          format = "[$symbol($project) ~ $region]($style)";
        };
        kubernetes = {
          disabled = false;
          context_aliases = {
            ".*stg_.*" = "stg";
            ".*test_.*" = "test";
            ".*prd_.*" = "prd";
          };
        };
      };
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      history.size = 1000000;

      localVariables = {
        CASE_SENSITIVE = "true";
        DISABLE_UNTRACKED_FILES_DIRTY = "true";
        RPROMPT = ""; # override because macOS defaults to filepath
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#838383,underline";
        ZSH_DISABLE_COMPFIX = "true";
      };

      envExtra = ''
        export PAGER=less
        export EDITOR=vim

        export PATH=$PATH:~/.cargo/bin
        export PATH=$PATH:~/.local/bin
        export PATH=$PATH:~/.npm-packages/bin
        export PATH=$PATH:/opt/homebrew/bin/
        export PATH=$PATH:~/bin
        export GOPATH=~/go
        export GOBIN=$GOPATH/bin
        export PATH=$PATH:$GOBIN

        export PATH=$HOME/.krew/bin:$PATH

        # homebrew for x86
        export PATH=$PATH:/usr/local/homebrew/bin
      '';

      initExtra = ''
        setopt noincappendhistory

        source $HOME/.zsh-work

        eval "$(jira --completion-script-bash)"

        if [[ "$OSTYPE" == "darwin"* ]]; then
          export PATH="$(brew --prefix)/opt/gnu-tar/libexec/gnubin:$PATH"
          export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"

          alias xdg-open=open
        fi

        # helm
        source <(helm completion zsh)

        # kubectl
        source <(kubectl completion zsh)

        # kubecolor
        source <(kubectl completion zsh)
        alias kubectl=kubecolor
        # make completion work with kubecolor
        compdef kubecolor=kubectl
      '';

      shellAliases = {
        ".." = "cd ..";
        c = "code";
        docker = "podman";
        g = "git";
        gr = "cd $(git rev-parse --show-toplevel)";
        gho = "gh repo view --web >/dev/null";
        grep = "rg --smart-case";
        k = "kubecolor";
        kcx = "kubectx";
        kns = "kubens";
        l = "exa -la --git --group-directories-first";
        m = "make";
        pia = "sudo openvpn --config ~/pia/$(find ~/pia -execdir basename {} .ovpn ';' -iname \"*.ovpn\" -type f | fzf --exact).ovpn";
        ps = "procs";
        t = "tmux-sessionizer";
        tf = "terraform";
        tree = "exa --tree";
        v = "nvim";
        nix-install = "nix-env -iA";
        brew-x86 = "arch -x86_64 /usr/local/homebrew/bin/brew";
      };

      "oh-my-zsh" = {
        enable = true;
        plugins = [
          "gitfast"
          "last-working-dir"
          "tmux"
        ];
      };
    };

    alacritty = {
      enable = true;
      settings = {
        window.padding.x = 10;
        window.padding.y = 10;
        scrolling.history = 100000;
        live_config_reload = true;
        mouse.hide_when_typing = true;

        font =
          if stdenv.isLinux
          then {
            normal.family = "Fira Code";
            size = 12;
          }
          else {
            normal.family = "FiraCode Nerd Font";
            size = 16;
          };

        shell = {
          program = "zsh";
          args = ["-l" "-c" "tmux" "u"];
        };

        colors = {
          primary.background = "0x101421";
          primary.foreground = "0xfffbf6";

          normal = {
            black = "0x2e2e2e";
            red = "0xeb4129";
            green = "0xabe047";
            yellow = "0xf6c744";
            blue = "0x47a0f3";
            magenta = "0x7b5cb0";
            cyan = "0x64dbed";
            white = "0xe5e9f0";
          };

          bright = {
            black = "0x565656";
            red = "0xec5357";
            green = "0xc0e17d";
            yellow = "0xf9da6a";
            blue = "0x49a4f8";
            magenta = "0xa47de9";
            cyan = "0x99faf2";
            white = "0xffffff";
          };

          key_bindings = [
            {
              key = "Home";
              mods = "Control";
              action = "ResetFontSize";
            }
            {
              key = "Plus";
              mods = "Control";
              action = "IncreaseFontSize";
            }
            {
              key = "Minus";
              mods = "Control";
              action = "DecreaseFontSize";
            }
          ];
        };
      };
    };

    go = {
      enable = true;
    };

    tmux = {
      enable = true;
      clock24 = true;
      terminal = "xterm-256color";
      customPaneNavigationAndResize = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = pain-control;
          extraConfig = "set -g @plugin 'tmux-plugins/tmux-pain-control'";
        }
        {
          plugin = sensible;
          extraConfig = "set -g @plugin 'tmux-plugins/tmux-sensible'";
        }
        {
          plugin = sessionist;
          extraConfig = "set -g @plugin 'tmux-plugins/tmux-sessionist'";
        }
        {
          plugin = yank;
          extraConfig = "set -g @plugin 'tmux-plugins/tmux-yank'";
        }
        {
          plugin = sensible;
          extraConfig = "set -g @plugin 'tmux-plugins/tmux-sensible'";
        }
        {
          plugin = tmux-colors-solarized;
          extraConfig = ''
            set -g @plugin 'seebi/tmux-colors-solarized'
            set -g @colors-solarized 'dark'
          '';
        }
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @plugin 'tmux-plugins/tmux-resurrect'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @plugin 'tmux-plugins/tmux-continuum'
            set -g @continuum-restore 'on'
          '';
        }
      ];
      extraConfig = ''
        set-window-option -g automatic-rename on
        set-option -g set-titles on

        set -g mouse on

        set -g status-left-length 30
        set -g status-right-length 150

        set -g xterm-keys on

        set -g pane-border-status top

        set -g set-titles on
        set -g display-panes-time 800
        set -g display-time 2000

        set -q -g utf8 on

        set -g monitor-activity on
        set -g visual-activity off

        set -g status-right '#(gitmux #{pane_current_path})'

      '';
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      # home-manager doesn't yet support `init.lua`
      extraConfig = "lua require('init')";

      plugins = with pkgs.vimPlugins; [
        cmp-nvim-lsp
        cmp-path
        cmp-treesitter
        diffview-nvim
        friendly-snippets
        gitlinker-nvim
        gitsigns-nvim
        gruvbox-nvim
        lualine-nvim
        luasnip
        nvim-cmp
        nvim-lspconfig
        nvim-tree-lua
        /*
         nvim-treesitter installed with packer for now
         */
        nvim-ts-rainbow
        nvim-web-devicons
        packer-nvim
        plenary-nvim
        telescope-fzy-native-nvim
        vim-commentary
        vim-markdown
        vim-repeat
        vim-sneak
        vim-surround
      ];
    };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions;
        [] ++ lib.optionals stdenv.isLinux [ms-vsliveshare.vsliveshare];
    };
  };

  home.file.".config/nvim/lua".source = ./nvim/lua;
  home.file.".config/srv".source = ./srv;

  home.file."..aws/config".source = ./.aws/config;
}
