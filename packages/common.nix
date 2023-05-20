{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) stdenv;
in {
  # System-wide packages to install.
  environment.systemPackages = with pkgs; let
    common = [
      # classics
      colordiff
      curl
      gcc
      git-crypt
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
      exa
      fd
      github-cli
      progress
      glab
      hadolint
      nodePackages.eslint
      oha
      postman
      pre-commit
      ripgrep
      yq-go
      shellcheck
      shfmt
      starship
      tldr
      tmux-sessionizer

      # containers
      k9s
      krew
      kube-score
      kubecolor
      kubectl
      kubectx
      kubernetes-helm
      kustomize
      minikube
      skaffold
      stern

      # language servers
      nodePackages.bash-language-server
      nodePackages.pyright
      nodePackages.yaml-language-server
      sumneko-lua-language-server

      # monitoring
      ctop
      glances
      htop
      procs

      # lua
      lua53Packages.luacheck
      stylua

      # golang
      golangci-lint
      gopls
      gofumpt

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
      whois

      # rice
      neofetch
      pfetch

      # backup
      rclone
      restic

      # infra
      terraform-ls
      terraformer
      tflint

      # nix
      alejandra
      cachix
      nix-diff
      nix-tree
      nixfmt
      nixpkgs-fmt
      nixpkgs-review
      rnix-lsp

      # cloud
      cloud-sql-proxy

      # python
      poetry
      python310
      python310Packages.black
      python310Packages.ipython
      python310Packages.pip
      python310Packages.poetry-core
      python310Packages.setuptools
      python310Packages.virtualenv

      # media
      youtube-dl

      # blog
      hugo
    ];
  in
    common;

  programs.gnupg.agent.enable = true;
}
