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

    # LSP
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

    # lua
    lua53Packages.luacheck
    stylua

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
    rnix-lsp

    # python
    poetry
    python310
    python310Packages.black
    python310Packages.ipython
    python310Packages.pip
    python310Packages.poetry-core
    python310Packages.setuptools
    python310Packages.virtualenv
  ];
}
