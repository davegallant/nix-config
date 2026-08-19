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
      bat
      btop
      curl
      czkawka
      doggo
      dust
      eza
      fd
      gdu
      github-cli
      gnumake
      gnupg
      just
      jq
      lsof
      macchina
      openvpn
      ncdu
      nix-tree
      nixd
      nixfmt
      bash-language-server
      yaml-language-server
      nvd
      progress
      rclone
      ripgrep
      shellcheck
      shfmt
      terraform-ls
      unstable.krew
      unstable.kubecolor
      unstable.kubectl
      unstable.kubectx
      unstable.kubectl-tree
      unstable.kubernetes-helm
      unstable.stern
      unzip
      viddy
      virtualenv
      yq-go
      zip
    ]
    ++ lib.optionals stdenv.isLinux [
      arp-scan
      cliphist
      cryptsetup
      dnsutils
      hardinfo2
      iperf
      iputils
      libsecret
      remmina
      nfs-utils
      nmap
      openssl
      pciutils
      socat
      qemu
      tcpdump
      traceroute
      usbutils
      vpngate.packages.${pkgs.stdenv.hostPlatform.system}.default
      whois
      wl-clip-persist
    ]
    ++ lib.optionals stdenv.isDarwin [
      # These shadow the BSD tools on PATH, so BSD flag syntax silently means
      # something else: `stat -f` is a format string on BSD but --file-system on
      # GNU, so `stat -f "%Sm"` prints filesystem stats instead of an mtime.
      # Call /usr/bin/stat or /usr/bin/sed when you want BSD behaviour.
      coreutils
      gnused
      gnutar
    ];
}
