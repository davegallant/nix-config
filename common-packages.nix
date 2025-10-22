{
  pkgs,
  unstable,
  ...
}:
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
    atuin
    bat
    cd-fzf
    doggo
    eza
    fd
    github-cli
    hadolint
    progress
    ripgrep
    shellcheck
    shfmt
    viddy
    yq-go

    # containers
    unstable.argocd
    unstable.k9s
    unstable.krew
    unstable.kubecolor
    unstable.kubectl
    unstable.kubectx
    unstable.kubernetes-helm
    unstable.stern

    # cloud
    awscli2
    google-cloud-sdk
    terraform

    # lsp
    nodePackages.bash-language-server
    nodePackages.eslint
    nodePackages.yaml-language-server
    terraform-ls

    # monitoring
    btop

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

    # rice
    fastfetch

    # nix
    nix-tree
    nixfmt-rfc-style
    nixpkgs-review

    # python
    poetry
    (unstable.python3.withPackages (ps: [
      ps.llm
      ps.llm-ollama
    ]))
    virtualenv

    # media
    yt-dlp
  ];
}
