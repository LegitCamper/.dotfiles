#!/usr/bin/bash
# updates nixos systems

cd ~/projects/.dotfiles/nix

# git restore .

git pull

# rm -rm flake.lock

# sudo nixos-rebuild switch  
# nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command  
sudo nixos-rebuild switch --upgrade --impure --flake .#nixos-desktop

nix-env --delete-generations 14d

nix-store --gc

cd -
