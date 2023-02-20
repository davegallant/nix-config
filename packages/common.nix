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
      # essentials
      colordiff
      curl
      gcc
      git-crypt
      gnupg
      imagemagick
      jq
      ripgrep
      unzip
      viddy
      xclip
      wget
      xdg-utils
      yq-go
      zip

      # productivity
      bat
      drone-cli
      exa
      fd
      github-cli
      gnumake
      hadolint
      nodePackages.eslint
      oha
      postman
      pre-commit
      shellcheck
      shfmt
      starship
      tldr
      tmux-sessionizer

      # containers
      k9s
      kube-score
      kubecolor
      kubectl
      kubectx
      kubernetes-helm
      kustomize
      minikube
      stern
      skaffold

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

      # video
      youtube-dl

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
      awscli2
      cloud-sql-proxy

      # python
      poetry
      pipx
      python311Full
      python311Packages.black
      python311Packages.ipython
      python311Packages.pip
      python311Packages.poetry-core
      python311Packages.setuptools
      python311Packages.virtualenv

      # blog
      hugo
    ];
  in
    common;

  programs.gnupg.agent.enable = true;
}
