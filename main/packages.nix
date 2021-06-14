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
        gnupg
        imagemagick
        pfetch
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

        # education
        anki

        # monitoring
        ctop
        glances
        htop
        netdata
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
        gimp

        # video
        youtube-dl

        # network
        arp-scan
        dnsutils
        nmap
        openssl
        openvpn
        sshfs # mac requires https://osxfuse.github.io/
        vpngate
        whois
        wireshark

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

        # news
        srv

      ] ++ lib.optionals stdenv.isLinux ([
        usbutils
        glibcLocales
        strace
        albert
        audio-recorder
        pulseeffects-pw
        guvcview
        kazam
        calibre
        spotify
        libreoffice
        vlc
        qemu
        virtmanager
        cryptsetup
        gptfdisk
        gnome3.gnome-tweaks
        gnomeExtensions.appindicator
        networkmanager-openvpn
        # Unsupported on darwin but likely should be:
        bandwhich
        brave
        datasette
        deluge
        discord
        firefox
        minecraft
        postman
        signal-desktop
        slack
        steam
        tailscale
        teams
        yuzu
        zoom-us
      ]);
    in
    common;

  # Install GnuPG agent.
  programs.gnupg.agent.enable = true;
}
