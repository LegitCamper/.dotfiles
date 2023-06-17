# updates nixos systems

cd ~/projects/.dotfiles/nix

git rebase .

git pull

nixos-rebuild --use-remote-sudo switch && 
nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command && 
nixos-rebuild --use-remote-sudo switch --impure --flake .#nixos-desktop

cd -
