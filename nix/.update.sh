#!/usr/bin/bash
# updates nixos systems

cd ~/projects/.dotfiles/nix

git pull

nix flake update

sudo nixos-rebuild switch --upgrade-all --install-bootloader --impure --use-substitutes --flake .#nixos-desktop

nix-env --delete-generations 14d

nix-store --gc

cd -
