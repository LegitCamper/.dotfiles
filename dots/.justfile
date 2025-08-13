create-toolbox:
  toolbox create --distro arch || \
  toolbox run --distro arch \
    sudo pacman -Sy just --noconfirm && just toolbox-dev
stow:
  @cd ~/projects/.dotfiles/ && stow -t ~ --adopt -S dots
  
install-package pkgs:
  sudo pacman -Sy {{pkgs}} --needed --noconfirm

toolbox-update:
  sudo pacman -Syu
  rustup update

dev-pkgs:='go gopls taplo cmake make lua-language-server ansible-language-server' 

toolbox-dev: toolbox-minimal toolbox-rust toolbox-python
  just install-package "{{dev-pkgs}}"

minimal-pkgs:= 'git openssh wget unzip fd stow fish htop yazi \
  jq fzf entr diffutils wl-clipboard helix lazygit eza atuin \
  zellij git-delta procs ripgrep starship macchina bat just \
  ansible marksmam base-devel'

toolbox-minimal: install-paru
  just install-package "{{minimal-pkgs}}"
  helix -g fetch
  helix -g build

install-paru:
  #!/bin/bash
  cd /tmp/ && git clone https://aur.archlinux.org/paru.git
  cd /tmp/paru
  makepkg -si
  rm -rf /tmp/paru

toolbox-rust:
  just install-package 'rustup pkgconf cmake'

  rustup component add rust-analyzer
  cargo install cargo-binstall
  cargo binstall cargo-binstall
  cargo binstall cargo-edit probe-rs-tools --no-confirm --continue-on-failure
  cargo binstall --git 'https://github.com/feel-ix-343/markdown-oxide' markdown-oxide --no-confirm

toolbox-python:
  just install-package 'python uv ruff'`
