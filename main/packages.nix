{ config, lib, pkgs, ... }:

{
  # System-wide packages to install.
  environment.systemPackages = with pkgs;
    let
      common = [
        # productivity
        albert
        bat
        bind
        binutils-unwrapped
        colordiff
        ctop
        curl
        direnv
        exa
        fd
        gcc
        git
        glances
        gnumake
        jq
        pre-commit
        procs
        remmina
        ripgrep
        rpi-imager
        strace
        tldr
        tokei
        tree
        unzip
        yq-go
        zip

        # printing
        ghostscript

        # education
        anki

        # monitoring
        htop

        # password managers
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
        python39Packages.setuptools
        python39Packages.virtualenv

        python38Packages.poetry # 3.9 doesn't work yet

        # ruby
        rbenv

        # databases
        postgresql

        # misc
        asciinema
        github-cli
        glibcLocales
        go-jira
        # hadolint
        imagemagick
        pfetch
        shellcheck
        shfmt
        starship
        xclip
        xdg_utils

        # gnome
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
        networkmanager-openvpn

        # overlays
        lpass
        rfd
        srv
        vpngate
      ];
    in common;

  # Don't install optional default packages.
  environment.defaultPackages = [ ];

  # Install ADB and fastboot.
  programs.adb.enable = true;

  # Install GnuPG agent.
  programs.gnupg.agent.enable = true;
}
