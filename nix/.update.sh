#!/usr/bin/bash
# updates nixos systems

cd ~/projects/.dotfiles/nix

git pull

# decrypt nix.conf github token
ansible-vault decrypt ~/.config/nix/nix.conf

sudo nix flake update

sudo nixos-rebuild switch --upgrade-all --impure --use-substitutes --flake .#nixos-desktop #  --install-bootloader

nix-env --delete-generations 14d

nix-store --gc

# decrypt nix.conf github token
ansible-vault encrypt ~/.config/nix/nix.conf

cd -
