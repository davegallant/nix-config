{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) stdenv;
in {
  # System-wide packages to install.
  environment.systemPackages = with pkgs; let
    common =
      [
        # essentials
        curl
        gcc
        git
        git-crypt
        gnupg
        imagemagick
        jq
        ripgrep
        unzip
        xclip
        xdg_utils
        zip

        # automation
        ansible

        # dev productivity
        ansible-lint
        bat
        checkov
        colordiff
        drone-cli
        exa
        fd
        github-cli
        gnumake
        go-jira
        hadolint
        httpie
        nodePackages.eslint
        pre-commit
        shellcheck
        shfmt
        starship
        tldr
        tmux-sessionizer

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
        nodePackages.pyright
        nodePackages.yaml-language-server
        rubyPackages.solargraph
        sumneko-lua-language-server

        # blog
        hugo

        # printing
        ghostscript

        # monitoring
        ctop
        glances
        htop
        iotop
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
        terraform-ls
        terraformer
        tflint
        tfsec
        /*
         tfswitch
         */
        infracost

        # nix
        alejandra
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
        awslogs
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

        # news
        srv
      ]
      ++ lib.optionals stdenv.isLinux [
        _1password-gui
        albert
        authy
        aws-sam-cli
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
        i3lock-fancy-rapid
        kazam
        keyleds
        linuxPackages.perf
        minecraft
        mojave-gtk-theme
        netdata
        nvfancontrol
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
        xautolock
        yaru-theme
        zoom-us
      ];
  in
    common;

  programs.gnupg.agent.enable = true;
}
