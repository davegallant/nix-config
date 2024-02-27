{
  config,
  lib,
  pkgs,
  unstable,
  ...
}: let
  inherit (pkgs) stdenv;
in {
  environment.systemPackages = with pkgs; [
    # essentials
    curl
    gcc
    gnumake
    gnupg
    imagemagick
    jq
    unzip
    viddy
    wget
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
    starship
    tldr
    tmux-sessionizer
    unstable.atuin
    unstable.github-cli
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
    unstable.awscli2
    unstable.azure-cli
    unstable.google-cloud-sdk

    # lsp
    nodePackages.bash-language-server
    nodePackages.pyright
    nodePackages.yaml-language-server
    sumneko-lua-language-server
    terraform-ls

    # monitoring
    ctop
    glances
    grafana-loki
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
    sshfs # mac requires https://osxfuse.github.io/
    tcpdump
    vpngate

    # rice
    neofetch
    pfetch

    # nix
    alejandra
    cachix
    nix-diff
    nix-tree
    nixfmt
    nixpkgs-fmt
    nixpkgs-review

    # python
    poetry
    python313
  ];
}