{ config, lib, pkgs, ... }:

let inherit (pkgs) stdenv;
in
{
  # System-wide packages to install.
  environment.systemPackages = with pkgs;
    let
      common = [
        # utils
        curl
        gcc
        gnupg
        imagemagick
        iotop
        unzip
        xdg_utils
        zip

        # dev tools
        ansible-lint
        checkov
        drone-cli
        git
        git-crypt
        github-cli
        gnumake
        hadolint
        nodePackages.eslint
        pre-commit
        shellcheck
        shfmt
        starship
        sumneko-lua-language-server

        # automation
        ansible

        # containers
        docker
        docker-compose
        kubectl
        kubernetes-helm
        kustomize
        minikube
        podman

        # language servers
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        nodePackages.pyright

        # productivity
        bat
        colordiff
        exa
        fd
        go-jira
        jq
        ripgrep
        tldr
        tmux-sessionizer
        xclip

        # blog
        hugo

        # printing
        ghostscript

        # monitoring
        ctop
        glances
        htop
        procs

        # data tools
        dbeaver

        # password managers
        _1password
        gopass
        rbw

        # lua
        lua53Packages.luacheck
        stylua

        # golang
        golangci-lint
        gopls
        gofumpt

        # js
        nodejs
        nodePackages.prettier
        nodePackages.yarn

        # video
        youtube-dl

        # networking
        arp-scan
        dnsutils
        iperf
        nmap
        openssl
        openvpn
        sshfs # mac requires https://osxfuse.github.io/
        vpngate
        whois

        # backup
        rclone
        restic

        # infra tools
        /* terraform-ls */
        terraformer
        tflint
        tfsec
        tfswitch
        infracost

        # nix
        cachix
        nix-diff
        nixfmt
        nixpkgs-fmt
        nixpkgs-review
        rnix-lsp

        ## aws
        aws-connect
        aws-role-play
        aws-vault
        awscli2
        /* awslogs */
        ssm-session-manager-plugin

        # python
        mypy
        python310
        python310Packages.black
        python310Packages.ipython
        python310Packages.pip
        python310Packages.poetry
        python310Packages.setuptools
        python310Packages.virtualenv

        # ruby
        rbenv
        rubocop
        ruby_2_7
        ruby_3_1
        rufo
        rubyPackages.solargraph

        # news
        srv

      ] ++ lib.optionals stdenv.isLinux ([
        _1password-gui
        albert
        authy
        /* aws-sam-cli */
        bitwarden
        brave
        calibre
        cryptsetup
        deluge
        discord
        firefox
        gimp
        glibcLocales
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
        google-chrome
        guake
        kazam
        linuxPackages.perf
        minecraft
        mojave-gtk-theme
        netdata
        pavucontrol
        pinentry-curses
        postman
        qemu
        rfd
        rtorrent
        rustup
        signal-desktop
        slack
        spotify
        steam
        strace
        tailscale
        usbutils
        virtmanager
        vlc
        wireshark-qt
        yaru-theme
        zoom-us
      ]);
    in
    common;

  programs.gnupg.agent.enable = true;
}
