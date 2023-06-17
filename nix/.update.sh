# updates nixos systems

cd ~/projects/.dotfiles/nix

git restore .

git pull

rm -rm flake.lock

nixos-rebuild --use-remote-sudo switch  
nix flake update --extra-experimental-features flakes --extra-experimental-features nix-command  
nixos-rebuild --use-remote-sudo switch --impure --flake .#nixos-desktop

cd -
