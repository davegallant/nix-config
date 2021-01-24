{ config, lib, pkgs, unstable, ... }:

{
  # System-wide packages to install.
  environment.systemPackages = with unstable;
    let
      common = [
        # utils
        bat
        bind
        binutils-unwrapped
        colordiff
        curl
        direnv
        exa
        fd
        gcc
        git
        gnumake
        jq
        remmina
        ripgrep
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

        # password
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

        # social media
        rtv

        # imaging
        gifsicle
        gimp

        # editors
        libreoffice
        vscodium

        # audio
        audio-recorder
        spotify

        # video
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
        tailscale

        # terraform
        terraform-ls
        terraform_0_14
        tflint
        tfsec

        # gcp
        google-cloud-sdk

        # jvm
        jdk8
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
        kubectl
        kubernetes-helm

        # nix
        nix-index
        nixfmt
        nixpkgs-fmt
        nixpkgs-review
        rnix-lsp

        # games
        steam
        minecraft
        yuzu

        # communication
        discord
        element-desktop
        signal-desktop
        slack
        zoom-us

        ## aws
        awscli2
        ssm-session-manager-plugin

        # python
        black
        python38
        python38Packages.ipython
        python38Packages.pip
        python38Packages.poetry
        python38Packages.setuptools
        python38Packages.virtualenv

        # misc
        asciinema
        github-cli
        glibcLocales
        go-jira
        hadolint
        nodejs-12_x
        imagemagick
        pfetch
        pinentry-curses
        shellcheck
        shfmt
        starship
        xclip
        xdg_utils
        zathura

        # gnome
        gnome3.gnome-tweaks

        # overlays
        lpass
        rfd
        srv
        vpngate
        g810-led

      ];
    in common;

  # Don't install optional default packages.
  environment.defaultPackages = [ ];

  # Install ADB and fastboot.
  programs.adb.enable = true;

  # Install GnuPG agent.
  programs.gnupg.agent.enable = true;
}
