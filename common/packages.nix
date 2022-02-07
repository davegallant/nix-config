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
        du-dust
        duf
        gnupg
        imagemagick
        pfetch
        unzip
        xdg_utils
        zip

        # dev tools
        act
        asciinema
        dive
        gcc
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
        tokei
        yq-go

        # containers
        docker
        docker-compose
        kubectl
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
        postgresql

        # password managers
        _1password
        gopass
        rbw

        # lua
        lua53Packages.luacheck
        stylua

        # golang
        golangci-lint
        golint
        gopls
        gofumpt

        # js
        nodePackages.prettier
        nodePackages.yarn

        # imaging
        gifsicle

        # video
        youtube-dl

        # networking
        arp-scan
        bandwhich
        dnsutils
        gping
        iperf
        nmap
        openssl
        openvpn
        sshfs # mac requires https://osxfuse.github.io/
        tcpdump
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
        tfswitch
        infracost

        # gcp
        google-cloud-sdk

        # nix
        cachix
        nix-diff
        nixfmt
        nixpkgs-fmt
        nixpkgs-review
        rnix-lsp

        # communication
        element-desktop

        ## aws
        aws-connect
        aws-role-play
        aws-vault
        awscli2
        awslogs
        ssm-session-manager-plugin

        # python
        mypy
        python39
        python39Packages.black
        python39Packages.ipython
        python39Packages.pip
        python39Packages.poetry
        python39Packages.setuptools
        python39Packages.virtualenv

        # ruby
        rbenv
        rubocop
        ruby_3_1
        rufo
        rubyPackages.solargraph

        # news
        srv

        # security
        yubikey-manager

      ] ++ lib.optionals stdenv.isLinux ([
        _1password-gui
        albert
        audio-recorder
        authy
        calibre
        cryptsetup
        firejail
        glibcLocales
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
        gptfdisk
        guake
        kazam
        libreoffice
        linuxPackages.perf
        pavucontrol
        pinentry-curses
        pulseeffects-pw
        qemu
        rtorrent
        rustup
        spotify
        strace
        usbutils
        virtmanager
        vlc
        # Unsupported / broken on darwin:
        aws-sam-cli
        bitwarden
        brave
        datasette
        deluge
        discord
        firefox
        gimp
        google-chrome
        minecraft
        postman
        rfd
        signal-desktop
        slack
        steam
        tailscale
        teams
        traceroute
        wireshark-qt
        zoom-us
        netdata
      ]);
    in
    common;

  programs.gnupg.agent.enable = true;
}
