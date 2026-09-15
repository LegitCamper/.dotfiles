create-toolbox:
  toolbox create

setup: create-toolbox 
  toolbox run bash -ic "sudo pacman -S just && just --justfile ~/projects/.dotfiles/.justfile toolbox-setup"

stow:
  @cd ~/projects/.dotfiles/ && stow -t ~ --adopt -S .
  
install-package pkgs:
  sudo pacman -Sy {{pkgs}} --needed --noconfirm

dev-pkgs:='go gopls taplo cmake make clang'# lua-language-server ansible-language-server' 

minimal-pkgs:= 'git openssh wget unzip stow htop yazi \
  jq fzf entr diffutils wl-clipboard helix lazygit eza \
  zellij git-delta ripgrep starship macchina just \
  typos typos-lsp ansible marksman base-devel openssh
  fuse fuse3 nspr nss atk cups gtk3 alsa-lib'

toolbox-setup: 
  grep '^en_US.UTF-8 UTF-8' /etc/locale.gen \
    || echo 'en_US.UTF-8 UTF-8' | sudo tee -a /etc/locale.gen
  sudo locale-gen

  just install-package "{{minimal-pkgs}}"
  just install-package "{{dev-pkgs}}"
  helix -g fetch
  helix -g build
  just toolbox-rust
  just toolbox-python

toolbox-rust:
  just install-package 'rustup pkgconf cmake'

  rustup update stable
  rustup default stable
  rustup update
  rustup component add rust-analyzer rust-src llvm-tools-preview
  cargo install cargo-binstall --locked
  cargo binstall -y --continue-on-failure cargo-edit probe-rs-tools
  cargo binstall -y --git 'https://github.com/feel-ix-343/markdown-oxide' markdown-oxide

toolbox-python:
  just install-package 'python uv ruff'
