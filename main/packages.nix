{ config, lib, pkgs, ... }:

{
  # System-wide packages to install.
  environment.systemPackages = with pkgs;
    let
      common = [
        # utils
        curl
        glibcLocales
        imagemagick
        pfetch
        rpi-imager
        strace
        tree
        unzip
        xdg_utils
        yq-go
        zip

        # dev tools 
        asciinema
        dive
        gcc
        git
        github-cli
        gnumake
        lazydocker
        lazygit
        pre-commit
        shellcheck
        shfmt
        starship
        tokei

        # productivity
        albert
        bat
        bind
        binutils-unwrapped
        colordiff
        direnv
        exa
        fd
        go-jira
        jq
        rfd
        ripgrep
        tldr
        xclip

        # printing
        ghostscript

        # education
        anki

        # monitoring
        ctop
        glances
        htop
        netdata
        procs

        # password managers
        bitwarden-cli
        gopass
        lpass

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
        gimp

        # office
        libreoffice

        # audio
        audio-recorder
        pulseeffects-pw
        spotify

        # video
        kazam
        youtube-dl
        vlc

        # network
        arp-scan
        bandwhich
        deluge
        nmap
        openssl
        openvpn
        postman
        sshfs
        tailscale
        vpngate

        # backup
        restic

        # virtualization
        qemu
        virtmanager

        # terraform
        terraform-ls
        terraform_0_14
        tflint
        tfsec

        # gcp
        google-cloud-sdk

        # jvm
        jdk11
        gradle
        groovy
        maven

        # encryption
        cryptsetup

        # browser
        brave
        firefox

        # docker
        docker
        docker-compose

        # k8s
        k3s
        kubectl
        kubernetes-helm

        # nix
        cachix
        nix-index
        nixfmt
        nixpkgs-fmt
        nixpkgs-review
        rnix-lsp
        # steam-run # can run unpatched binaries

        # games
        steam
        minecraft
        # yuzu

        # communication
        discord
        element-desktop
        signal-desktop
        slack
        teams
        zoom-us

        ## aws
        aws-connect
        awscli2
        ssm-session-manager-plugin

        # python
        pipenv
        python39
        python39Packages.black
        python39Packages.ipython
        python39Packages.pip
        python39Packages.poetry
        python39Packages.setuptools
        python39Packages.virtualenv

        # ruby
        rbenv

        # databases
        postgresql

        # gnome
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
        networkmanager-openvpn

        # news
        srv
      ];
    in common;

  # Don't install optional default packages.
  environment.defaultPackages = [ ];

  # Install ADB and fastboot.
  programs.adb.enable = true;

  # Install GnuPG agent.
  programs.gnupg.agent.enable = true;
}
