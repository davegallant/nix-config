{ config
, lib
, pkgs
, unstable
, ...
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
    unstable.atuin
    unstable.github-cli
    viddy
    yq-go

    # containers
    krew
    kubecolor
    kubectl
    kubectx
    minikube
    stern
    unstable.helm-docs
    unstable.kubernetes-helm
    unstable.k9s
    unstable.skaffold

    # cloud
    unstable.aws-vault
    unstable.awscli2
    unstable.azure-cli
    unstable.google-cloud-sdk
    unstable.terraform

    # lsp
    nodePackages.bash-language-server
    nodePackages.pyright
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
    pfetch

    # nix
    nix-tree
    nixpkgs-fmt
    nixpkgs-review

    # python
    poetry
    python313
    virtualenv
  ];
}
