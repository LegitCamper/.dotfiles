#!/usr/bin/bash
# updates nixos systems

cd ~/projects/.dotfiles/nix

git pull

sudo nix flake update

sudo nixos-rebuild switch --upgrade-all --impure --use-substitutes --flake .#nixos-desktop #  --install-bootloader

nix-env --delete-generations 14d

nix-store --gc

cd -
