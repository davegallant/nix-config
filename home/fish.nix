{
  lib,
  pkgs,
  pvectl,
  unstable,
  vpngate,
  ...
}:
{
  xdg.configFile = {
    "fish/completions/kubectl.fish".source = pkgs.runCommand "kubectl-completions.fish" { } ''
      ${unstable.kubectl}/bin/kubectl completion fish > $out
    '';
    "fish/completions/helm.fish".source = pkgs.runCommand "helm-completions.fish" { } ''
      ${unstable.kubernetes-helm}/bin/helm completion fish > $out
    '';
    "fish/completions/pvectl.fish".source = pkgs.runCommand "pvectl-completions.fish" { } ''
      ${pvectl.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/pvectl completion fish > $out
    '';
    "fish/completions/vpngate.fish".source = pkgs.runCommand "vpngate-completions.fish" { } ''
      ${vpngate.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/vpngate completion fish > $out
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
          disabled = true;
        };
        nix_shell = {
          disabled = true;
        };
        custom.kube = {
          command = ''grep '^current-context:' "$HOME/.kube/config" | awk '{print $2}' '';
          when = ''test -f "$HOME/.kube/config"'';
          symbol = "☸ ";
          format = "[$symbol$output]($style) ";
          style = "bold cyan";
        };
      };
    };

    fish = {
      enable = true;

      functions = {
        gh-clone = ''
          set dest (command gh-clone $argv | head -1)
          if test -n "$dest"
            cd $dest
          end
        '';
        s = ''
          set selected (fd --type d --exact-depth 3 --base-directory ~/src | fzf --exact)
          if test -n "$selected"
            cd ~/src/$selected
          end
        '';
        cr = ''
          # Pick a Claude Code session from any project (see ~/.claude/claude-resume.sh),
          # then cd into its directory and resume it.
          set -l sel (~/.claude/claude-resume.sh)
          test -n "$sel"; or return
          set -l parts (string split \t -- $sel)
          cd $parts[1]; and claude --resume $parts[2]
        '';
        kdebug = "kubectl run debug-(random) --image=nicolaka/netshoot --restart=Never -it --rm -- bash";
        kdesc = ''
          set pod (kubectl get pods -o name | fzf)
          test -n "$pod"; and kubectl describe $pod
        '';
        kex = ''
          set pod (kubectl get pods -o name | fzf)
          test -n "$pod"; or return
          set containers (kubectl get $pod -o jsonpath='{.spec.containers[*].name}' | string split ' ')
          if test (count $containers) -gt 1
            set container (printf '%s\n' $containers | fzf)
            test -n "$container"; and kubectl exec -it $pod -c $container -- sh -c 'bash || sh'
          else
            kubectl exec -it $pod -- sh -c 'bash || sh'
          end
        '';
        klog = ''
          set pod (kubectl get pods -o name | fzf)
          test -n "$pod"; and kubectl logs -f $pod --all-containers
        '';
      };

      interactiveShellInit = ''
        set fish_greeting

        fish_vi_key_bindings
        bind -M insert \cw backward-kill-word
        bind -M insert \ce end-of-line
        bind -M insert \ca beginning-of-line

        set -x DOCKER_CLI_HINTS false
        set -x DOCKER_DEFAULT_PLATFORM linux/amd64
        set -x EDITOR vim
        set -x PAGER less
        ${lib.optionalString pkgs.stdenv.isDarwin ''
          set secretive_sock $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
          if test -S $secretive_sock
            set -x SSH_AUTH_SOCK $secretive_sock
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

        test -f $HOME/.config/fish/work.fish && source $HOME/.config/fish/work.fish
        test -f $HOME/.config/fish/private.fish && source $HOME/.config/fish/private.fish
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
        hd = "hunk diff";
        hdc = "hunk diff --cached";
        hs = "hunk show";
        j = "just";
        k = "kubecolor";
        kubectl = "kubecolor";
        kcx = "kubectx";
        kevents = "kubectl get events --sort-by=.lastTimestamp -A";
        kpf = "kubectl port-forward --address 0.0.0.0";
        ktree = "kubectl tree";
        kns = "kubens";
        l = "eza -la --git --group-directories-first";
        m = "make";
        pi-review = "pi --tools read,grep,find,ls -p";
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
