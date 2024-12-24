{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  environment.systemPackages = with pkgs; [
    # essentials
    curl
    gnumake
    gnupg
    jq
    unzip
    xclip
    xdg-utils
    zip

    # modern cli
    bat
    doggo
    eza
    fd
    hadolint
    nodePackages.eslint
    oha
    pre-commit
    progress
    ripgrep
    shellcheck
    shfmt
    tldr
    tmux-sessionizer
    atuin
    
    github-cli
    viddy
    yq-go

    # containers
    krew
    kubecolor
    kubectl
    kubectx
    minikube
    stern
    dive
    helm-docs
    k9s
    kubernetes-helm

    # cloud
    awscli2
    google-cloud-sdk
    terraform

    # lsp
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
    terraform-ls

    # monitoring
    htop
    procs

    # golang
    gofumpt
    golangci-lint
    gopls

    # rust
    rustup

    # js
    nodejs
    nodePackages.prettier
    nodePackages.yarn

    # networking
    arp-scan
    dnsutils
    iperf
    nmap
    openssl
    openvpn
    tcpdump
    vpngate

    # rice
    neofetch

    # nix
    nix-tree
    nixfmt-rfc-style
    nixpkgs-review

    # python
    poetry
    python313
    virtualenv

    # media
    yt-dlp
  ];
}
