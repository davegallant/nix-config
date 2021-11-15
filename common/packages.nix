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
        # hadolint # broken
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
        exa
        fd
        go-jira
        jq
        ripgrep
        tldr
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
        postgresql

        # password managers
        _1password
        bitwarden-cli
        gopass

        # lua
        lua53Packages.luacheck
        stylua

        # golang
        golangci-lint
        golint
        gopls

        # js
        nodePackages.prettier
        nodePackages.yarn

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

        # backup
        restic

        # terraform
        terraform-ls
        terraform
        terraformer
        tflint
        tfsec

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
        python39
        python39Packages.black
        python39Packages.ipython
        python39Packages.pip
        python39Packages.pipx
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
        yubikey-manager

      ] ++ lib.optionals stdenv.isLinux ([
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
        guvcview
        kazam
        kazam
        libreoffice
        linuxPackages.perf
        networkmanager-openvpn
        opensnitch
        opensnitch-ui
        pinentry-curses
        podman
        pulseeffects-pw
        qemu
        rtorrent
        rustup
        spotify
        strace
        usbutils
        virtmanager
        vlc
        # Unsupported or broken on darwin:
        aws-sam-cli
        bitwarden
        brave
        rfd
        datasette
        deluge
        discord
        firefox
        gimp
        minecraft
        nfs-utils
        postman
        signal-desktop
        slack
        steam
        tailscale
        teams
        wireshark-qt
        yuzu
        zoom-us
        netdata # TODO: Enable launchd support with nix-darwin
      ]);
    in
    common;

  # Install GnuPG agent.
  programs.gnupg.agent.enable = true;
}
