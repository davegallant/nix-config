{
  pkgs,
  lib,
  master,
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
      # essentials
      curl
      gnumake
      gnupg
      jq
      unzip
      zip
      lsof

      # modern cli
      atuin
      bat
      cd-fzf
      doggo
      eza
      fd
      github-cli
      hadolint
      lazygit
      macchina
      ncdu
      progress
      ripgrep
      shellcheck
      shfmt
      viddy
      yq-go

      # containers
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

      # nix
      nix-tree
      nixfmt-rfc-style
      nixpkgs-review
      nvd

      # python
      virtualenv

      # media
      yt-dlp
    ]
    ++ lib.optionals stdenv.isLinux [
      xclip
      xdg-utils

      # networking
      arp-scan
      dnsutils
      iperf
      nmap
      openssl
      openvpn
      tcpdump

      # desktop apps
      bitwarden-desktop
      dbeaver-bin
      discord
      feishin
      freefilesync
      gimp-with-plugins
      httpie-desktop
      mission-center
      onlyoffice-desktopeditors
      pika-backup
      pinta
      qbittorrent
      unstable.brave
      unstable.obsidian
      unstable.podman-desktop
      unstable.signal-desktop
      unstable.zoom-us

      # keyboard
      via

      # gaming
      heroic
      ludusavi
      mupen64plus
      protonup-qt
      unstable.ryubing
      unstable.lutris
      wine

      # media
      calibre
      libation
      unstable.spotify
      vlc

      # networking
      iputils
      traceroute
      unstable.ktailctl
      unstable.tailscale
      vpngate.packages.${pkgs.stdenv.hostPlatform.system}.default
      whois

      # security
      bleachbit
      clamtk
      cryptsetup
      libsecret # D-Bus secret service client (used by Electron apps)
      opensnitch-ui
      pinentry-curses

      # system utilities
      hardinfo2
      nfs-utils
      pciutils
      unstable.ghostty
      qemu
      unrar
      unstable.beszel
      usbutils
      virt-manager
      wayland-utils
      wl-clipboard

      # llm
      bun
      unstable.code-cursor
    ];
}
