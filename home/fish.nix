{
  config,
  lib,
  pkgs,
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
        time = {
          disabled = false;
          format = "[$time]($style) ";
          time_format = "%I:%M %p";
          style = "dimmed white";
        };
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

        ${lib.optionalString config.features.headless.enable ''
          if test -f ~/.last_dir
            cd (cat ~/.last_dir)
          end
        ''}

        fish_vi_key_bindings
        bind -M insert \cw backward-kill-word
        bind -M insert \ce end-of-line
        bind -M insert \ca beginning-of-line

        set -x DOCKER_CLI_HINTS false
        ${lib.optionalString (
          !config.features.headless.enable
        ) "set -x DOCKER_DEFAULT_PLATFORM linux/amd64"}
        set -x EDITOR vim
        set -x NNN_FIFO "$XDG_RUNTIME_DIR/nnn.fifo"
        set -x PAGER less
        ${lib.optionalString (pkgs.stdenv.isLinux && !config.features.headless.enable) ''
          if test -S $HOME/.bitwarden-ssh-agent.sock
            set -x SSH_AUTH_SOCK $HOME/.bitwarden-ssh-agent.sock
          else
            set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
          end
        ''}
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

        function kdebug
          kubectl run debug-(random) --image=nicolaka/netshoot --restart=Never -it --rm -- bash
        end

        function kdesc
          set pod (kubectl get pods -o name | fzf)
          test -n "$pod"; and kubectl describe $pod
        end

        function kex
          set pod (kubectl get pods -o name | fzf)
          test -n "$pod"; or return
          set containers (kubectl get $pod -o jsonpath='{.spec.containers[*].name}' | string split ' ')
          if test (count $containers) -gt 1
            set container (printf '%s\n' $containers | fzf)
            test -n "$container"; and kubectl exec -it $pod -c $container -- sh -c 'bash || sh'
          else
            kubectl exec -it $pod -- sh -c 'bash || sh'
          end
        end

        function klog
          set pod (kubectl get pods -o name | fzf)
          test -n "$pod"; and kubectl logs -f $pod --all-containers
        end

        test -f $HOME/.config/fish/work.fish && source $HOME/.config/fish/work.fish
        test -f $HOME/.config/fish/workprivate.fish && source $HOME/.config/fish/private.fish
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
        gho = "gh repo view --json url --jq .url; gh repo view --web 2>/dev/null";
        gr = "cd $(git rev-parse --show-toplevel)";
        grep = "rg --smart-case";
        j = "just";
        k = "kubecolor";
        kubectl = "kubecolor";
        kcx = "kubectx";
        kevents = "kubectl get events --sort-by=.lastTimestamp -A";
        ktree = "kubectl tree";
        kns = "kubens";
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
