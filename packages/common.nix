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
      curl
      gcc
      git
      git-crypt
      gnupg
      imagemagick
      jq
      ripgrep
      unzip
      xclip
      xdg_utils
      yq-go
      zip

      # ansible
      /*
       ansible
       */
      /*
       ansible-lint
       */

      # productivity
      bat
      /*
       checkov
       */
      colordiff
      drone-cli
      exa
      fd
      github-cli
      gnumake
      go-jira
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
      kubectl
      kubernetes-helm
      kustomize
      minikube
      stern

      # language servers
      nodePackages.bash-language-server
      nodePackages.pyright
      nodePackages.yaml-language-server
      sumneko-lua-language-server

      # monitoring
      ctop
      /*
       glances
       */
      htop
      procs

      # lua
      lua53Packages.luacheck
      stylua

      # golang
      golangci-lint
      gopls
      gofumpt

      # js
      nodejs
      nodePackages.prettier
      nodePackages.yarn

      # video
      youtube-dl

      # networking
      arp-scan
      /*
       dnsutils
       */
      iperf
      nmap
      openssl
      openvpn
      sshfs # mac requires https://osxfuse.github.io/
      vpngate
      whois

      # backup
      rclone
      restic

      # infra
      terraform-ls
      terraformer
      tflint
      tfswitch
      infracost

      # nix
      alejandra
      cachix
      nix-diff
      nixfmt
      nixpkgs-fmt
      nixpkgs-review
      rnix-lsp

      # cloud
      /*
       awscli2
       */
      ssm-session-manager-plugin
      google-cloud-sdk

      # python
      python310
      /*
       python310Packages.black
       */
      python310Packages.ipython
      python310Packages.pip
      /*
       python310Packages.poetry
       */
      python310Packages.setuptools
      python310Packages.virtualenv

      # blog
      hugo

      # news
      srv
    ];
  in
    common;

  programs.gnupg.agent.enable = true;
}
