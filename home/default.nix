{ lib, pkgs, ... }:

let
  vim-prettier = pkgs.vimUtils.buildVimPlugin {
    name = "vim-prettier";
    src = pkgs.fetchFromGitHub {
      owner = "prettier";
      repo = "vim-prettier";
      rev = "0.2.7";
      sha256 = "sha256-FDeyGH5OPAYV7zePCfDujsj+nGd5AFnqySPStJYEY2E=";
    };
  };
  inherit (pkgs) stdenv;
in
{

  services = {
    gpg-agent = {
      enable = stdenv.isLinux;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      enableSshSupport = true;
    };
  };

  fonts.fontconfig.enable = true;

  programs = {

    home-manager.enable = true;

    git = {
      enable = true;

      userName = "Dave Gallant";

      aliases = {
        "aa" = "add -A .";
        "br" = "branch";
        "ca" = "commit -S --amend";
        "cb" = "checkout -b";
        "ci" = "commit";
        "cm" = "commit -m";
        "co" = "checkout";
        "cs" = "commit -S";
        "csm" = "commit -S -m";
        "csa" = "commit -S --amend";
        "deleted" = "log --diff-filter=D --summary";
        "di" = "diff";
        "dic" = "diff --cached";
        "dicn" = "diff --cached --name-only";
        "din" = "diff --name-only";
        "l" =
          "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        "ms" = "merge --squash";
        "pb" = "pull --rebase";
        "po" = "push origin";
        "por" = "push origin HEAD:refs/for/$1";
        "st" = "status";
        "wip" =
          "for-each-ref --sort='authordate:iso8601' --format=' %(color:green)%(authordate:relative)%09%(color:white)%(refname:short)' refs/heads";
      };

      includes = [{ path = "~/.gitconfig-work"; }];

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
        push = { default = "current"; };
        pull = { rebase = true; };
      };

    };

    starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;
        gcloud = { disabled = true; };
        scan_timeout = 10;
        character = { error_symbol = "[✖](bold red)"; };
      };
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      history.size = 1000000;

      localVariables = {
        CASE_SENSITIVE = "true";
        DISABLE_UNTRACKED_FILES_DIRTY = "true";
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#838383,underline";
        ZSH_DISABLE_COMPFIX = "true";
      };

      initExtra = ''
        export PATH=$PATH:~/.cargo/bin
        export PATH=$PATH:~/.local/bin
        export PATH=$PATH:~/go/bin
        export PAGER=less
        export EDITOR=vim

        eval "$(direnv hook zsh)"
        eval "$(_RFD_COMPLETE=source_zsh rfd)"
        eval "$(jira --completion-script-zsh)"

        setopt noincappendhistory
        pfetch
      '';

      shellAliases = {
        aws-azure-login =
          "docker run --rm -it -v ~/.aws:/root/.aws sportradar/aws-azure-login";
        ".." = "cd ..";
        grep = "rg --smart-case";
        k = "kubectl";
        ls = "exa -la --git";
        ps = "procs";
      };

      "oh-my-zsh" = {
        enable = true;
        plugins = [ "git" "last-working-dir" ];
      };

      plugins = [{
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }];
    };

    alacritty = {
      enable = true;
      settings = {
        window.padding.x = 10;
        window.padding.y = 10;
        scrolling.history = 100000;
        live_config_reload = true;
        mouse.hide_when_typing = true;

        font = {
          normal.family = "Fira Code";
          size = 12;
        };

        shell = {
          program = "zsh";
          args = [ "-l" "-c" "tmux" "u" ];
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
      goBin = "go/bin";
      goPath = "go";
    };

    tmux = {
      enable = true;
      clock24 = true;
      terminal = "screen-256color";
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
          plugin = tmux-colors-solarized;
          extraConfig = ''
            set -g @plugin 'seebi/tmux-colors-solarized'
            set -g @colors-solarized 'dark'
          '';
        }
      ];
      extraConfig = ''
        set-window-option -g automatic-rename on
        set-option -g set-titles on

        set -g mouse on

        # Length of tmux status line
        set -g status-left-length 30
        set -g status-right-length 150

        set -g status-interval 5

        set -g default-terminal "screen-256color" # colors!
        setw -g xterm-keys on

        set -g set-titles on          # set terminal title
        set -g display-panes-time 800 # slightly longer pane indicators display time
        set -g display-time 2000      # slightly longer status messages display time

        # Lots of scrollback.
        setw -g history-limit 50000000

        setw -q -g utf8 on

        # activity
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

      extraConfig = builtins.readFile ./nvim/init.vim;
      plugins = with pkgs.vimPlugins; [
        coc-go
        coc-json
        coc-nvim
        coc-rls
        fzf-vim
        fzfWrapper
        gruvbox
        nerdtree
        rust-vim
        supertab
        syntastic
        tabular
        typescript-vim
        vim-commentary
        vim-fugitive
        vim-gitgutter
        vim-go
        vim-javacomplete2
        vim-javascript
        vim-markdown
        vim-nix
        vim-pandoc
        vim-prettier
        vim-pandoc-syntax
        vim-repeat
        vim-sneak
        vim-surround
        vim-terraform
      ];

    };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions;
        [ ] ++ lib.optionals stdenv.isLinux ([ ms-vsliveshare.vsliveshare ]);
    };

  };

  home.file.".config/nvim/statusline.vim".source = ./nvim/statusline.vim;
  home.file.".config/srv/config.yml".source = ./srv/config.yml;

}
