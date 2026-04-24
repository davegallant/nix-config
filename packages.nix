{
  pkgs,
  lib,
  unstable,
  vpngate,
  ...
}:
let
  inherit (pkgs) stdenv;
in
{
  environment.systemPackages =
    with pkgs;
    [
      # cli
      atuin
      bat
      cd-fzf
      curl
      doggo
      eza
      fd
      github-cli
      gnumake
      gnupg
      hadolint
      jq
      lazygit
      lsof
      macchina
      ncdu
      progress
      ripgrep
      shellcheck
      shfmt
      unzip
      viddy
      yq-go
      zip

      # containers
      unstable.krew
      unstable.kubecolor
      unstable.kubectl
      unstable.kubectx
      unstable.kubernetes-helm
      unstable.stern

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

      # nix
      nil
      nix-tree
      nixd
      nixfmt-rfc-style
      nixpkgs-review
      nvd

      # python
      virtualenv

      # media
      yt-dlp
    ]
    ++ lib.optionals stdenv.isLinux [
      # networking
      arp-scan
      dnsutils
      iperf
      iputils
      nmap
      openssl
      openvpn
      tcpdump
      traceroute
      unstable.tailscale
      vpngate.packages.${pkgs.stdenv.hostPlatform.system}.default
      whois

      # security
      cryptsetup
      libsecret

      # clipboard
      cliphist
      wl-clip-persist

      # system utilities
      hardinfo2
      nfs-utils
      pciutils
      qemu
      unrar
      unstable.beszel
      usbutils

      # llm
      bun
    ];
}
