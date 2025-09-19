create-toolbox:
  toolbox create --distro arch || \
  toolbox run --distro arch sudo pacman -Sy just --noconfirm
stow:
  @cd ~/projects/.dotfiles/ && stow -t ~ --adopt -S dots
  
install-package pkgs:
  sudo pacman -Sy {{pkgs}} --needed --noconfirm

toolbox-update:
  sudo pacman -Syu
  rustup update

dev-pkgs:='go gopls taplo cmake make lua-language-server ansible-language-server' 

minimal-pkgs:= 'git openssh wget unzip fd stow fish htop yazi \
  jq fzf entr diffutils wl-clipboard helix lazygit eza atuin \
  zellij git-delta procs ripgrep starship macchina bat just \
  typos ansible marksman base-devel'

toolbox-setup: toolbox-rust toolbox-python
  just install-package "{{minimal-pkgs}}"
  just install-package "{{dev-pkgs}}"
  helix -g fetch
  helix -g build

toolbox-rust:
  just install-package 'rustup pkgconf cmake'

  rustup component add rust-analyzer
  cargo install cargo-binstall --locked
  cargo binstall cargo-binstall
  cargo binstall cargo-edit probe-rs-tools aura-pm --no-confirm --continue-on-failure
  cargo binstall --git 'https://github.com/feel-ix-343/markdown-oxide' markdown-oxide --no-confirm

toolbox-python:
  just install-package 'python uv ruff'
