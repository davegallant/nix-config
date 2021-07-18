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
        pinentry-curses
        tree
        unzip
        xdg_utils
        yq-go
        zip

        # dev tools
        act
        asciinema
        chromedriver
        dive
        gcc
        git
        git-crypt
        github-cli
        gnumake
        lazydocker
        lazygit
        pre-commit
        shellcheck
        shfmt
        starship
        tokei

        # language servers
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        nodePackages.pyright

        # productivity
        bat
        colordiff
        direnv
        exa
        fd
        jq
        rfd
        ripgrep
        tldr
        xclip

        # printing
        ghostscript

        # monitoring
        ctop
        glances
        htop
        procs

        # data tools
        postgresql

        # password managers
        _1password
        bitwarden-cli
        gopass

        # golang
        golangci-lint
        golint
        gopls

        # rust
        cargo
        rls
        rust-analyzer
        rustPackages.clippy
        rustc
        rustfmt

        # node
        nodejs-14_x
        nodePackages.prettier
        nodePackages.yarn

        # social media
        rtv

        # imaging
        gifsicle

        # video
        youtube-dl

        # network
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
        wireshark-qt

        # backup
        restic

        # terraform
        terraform-ls
        terraform_0_14
        tflint
        tfsec

        # gcp
        google-cloud-sdk

        # docker
        docker
        docker-compose

        # k8s
        kubectl

        # nix
        cachix
        nix-diff
        # nix-query-tree-viewer
        nixfmt
        nixpkgs-fmt
        nixpkgs-review
        rnix-lsp

        # communication
        element-desktop

        ## aws
        aws-connect
        # aws-sam-cli # broken!
        awscli2
        ssm-session-manager-plugin

        # python
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
        ruby
        rufo
        rubyPackages.solargraph

        # news
        srv

        # security
        yar
        yubikey-manager

      ] ++ lib.optionals stdenv.isLinux ([
        albert
        audio-recorder
        calibre
        cryptsetup
        firejail
        glibcLocales
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
        gptfdisk
        guvcview
        kazam
        libreoffice
        networkmanager-openvpn
        pulseeffects-pw
        qemu
        rtorrent
        spotify
        strace
        usbutils
        virtmanager
        vlc
        # Unsupported on darwin but likely should be:
        brave
        datasette
        deluge
        discord
        firefox
        gimp
        minecraft
        postman
        signal-desktop
        slack
        steam
        tailscale
        teams
        yuzu
        zoom-us
        netdata # TODO: Enable launchd support with nix-darwin
      ]);
    in
    common;

  # Install GnuPG agent.
  programs.gnupg.agent.enable = true;
}
