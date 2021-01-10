{ pkgs }:

with pkgs; [

  # utils
  bat
  bind
  colordiff
  curl
  direnv
  exa
  fd
  fzf
  git
  gnumake
  jq
  ripgrep
  tree
  unzip
  zip

  # monitoring
  htop

  # password
  gopass

  # social media
  rtv

  # imaging
  gimp

  # editors
  libreoffice
  vscodium

  # audio
  audio-recorder
  spotify

  # video
  youtube-dl
  vlc

  # network
  bandwhich
  deluge
  nmap
  openvpn
  postman

  # go
  go

  # terraform
  terraform-ls
  terraform_0_14
  tflint
  tfsec

  # cloud
  google-cloud-sdk

  # jvm
  jdk8
  gradle
  groovy
  maven

  # encryption
  cryptsetup

  # browser
  brave
  firefox

  # docker
  docker
  docker-compose

  # k8s
  kubectl
  kubernetes-helm

  # nix
  nixpkgs-fmt
  rnix-lsp

  # games
  steam
  minecraft
  yuzu

  # communication
  discord
  element-desktop
  signal-desktop
  slack

  ## aws
  awscli2
  ssm-session-manager-plugin

  # python
  black
  python38
  python38Packages.ipython
  python38Packages.pip
  python38Packages.poetry
  python38Packages.setuptools
  python38Packages.virtualenv

  # fonts
  dejavu_fonts
  fira-code
  fira-code-symbols
  fira-mono
  font-awesome
  google-fonts
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra

  # misc
  asciinema
  github-cli
  glibcLocales
  go-jira
  hadolint
  nodejs-12_x
  imagemagick
  pfetch
  pinentry-curses
  shellcheck
  shfmt
  starship
  xclip
  xdg_utils
  zathura

  # overlays
  rfd
  lpass
  zoom
]
