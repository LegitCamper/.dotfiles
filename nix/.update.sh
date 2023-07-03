#!/usr/bin/bash
# updates nixos systems

cd ~/projects/.dotfiles/nix

git pull

# decrypt nix.conf github token
ansible-vault decrypt ~/.config/nix/nix.conf

nix flake update

nixos-rebuild switch --upgrade-all --use-remote-sudo --impure --use-substitutes --flake .#nixos-desktop #  --install-bootloader

nix-env --delete-generations 14d

nix-store --gc

# decrypt nix.conf github token
ansible-vault encrypt ~/.config/nix/nix.conf

cd -
