{
  lib,
  pkgs,
  hostname ? "",
  ...
}:
{
  xdg.configFile = {
    "fish/completions/kubectl.fish".source = pkgs.runCommand "kubectl-completions.fish" { } ''
      ${pkgs.kubectl}/bin/kubectl completion fish > $out
    '';
    "fish/completions/helm.fish".source = pkgs.runCommand "helm-completions.fish" { } ''
      ${pkgs.kubernetes-helm}/bin/helm completion fish > $out
    '';
  };

  programs = {
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

        function __save_last_dir --on-event fish_prompt
          echo $PWD > ~/.last_dir
        end

        ${lib.optionalString (hostname == "kratos") ''
          if test -f ~/.last_dir
            cd (cat ~/.last_dir)
          end
        ''}


        bind \cw backward-kill-word

        set -x DOCKER_CLI_HINTS false
        ${lib.optionalString (hostname != "kratos") "set -x DOCKER_DEFAULT_PLATFORM linux/amd64"}
        set -x EDITOR vim
        set -x NNN_FIFO "$XDG_RUNTIME_DIR/nnn.fifo"
        set -x PAGER less
        ${lib.optionalString (
          pkgs.stdenv.isLinux && hostname != "kratos"
        ) "set -x SSH_AUTH_SOCK /home/dave/.bitwarden-ssh-agent.sock"}
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

        test -f $HOME/work.fish && source $HOME/work.fish
      '';

      shellInit = ''
        set -x GH_TELEMETRY false
        set -x DO_NOT_TRACK true
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
        kcx = "kubectx";
        kns = "kubens";
        krun = "kubectl run ubuntu-shell --image=ubuntu --restart=Never -it --rm -- /bin/bash";
        l = "eza -la --git --group-directories-first";
        m = "make";
        oc = "opencode";
        t = "cd $(cd-fzf)";
        tf = "terraform";
        tree = "eza --tree";
        v = "nvim";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        zed = "zeditor";
      };
    };
  };
}
